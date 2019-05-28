@include "messages.awk"

BEGIN {
    current_content[0] = ""
    content_ind = 0
    images[0] = ""
    images_ind
    float = "none"
    close_div = 0
    close_tc = 0
    close_aside = 0
    normal_lines = 0
    reset_counters()
}

function reset_counters(){
    content_ind = 0
    images_ind = 0
    normal_lines = 0
    delete current_content # Note that this is a gawk extension
    delete images
}

function build_image_split(image_list){
    kind[2] = "two"
    kind[3] = "three"
    kind[4] = "four"
    kind[5] = "five"
    class = kind[length(image_list)]
    for (i in image_list){
        path = substr(image_list[i], 4, 999)
        converted = "<div class='" class "-image overlay' style=\"background-image: url" path ";\"></div>"
        image_list[i] = converted
    }
}

function build_image(image_list,    position, path, reverse, class){
    image = image_list[0]
    reverse["left"] = "right"
    reverse["right"] = "left"
    reverse["fit"] = "center"
    if(image ~ /\[left/){
        path = gensub(/!\[left[^\]]*\]/, "", "g", image)
        position = "left"
        if(image ~ /fit/){
            class = "half-image-fit"
        } else {
            class = "half-image-cover"
        }
    } else if(image ~ /\[right/){
        path = gensub(/!\[right[^\]]*\]/, "", "g", image)
        position = "right"
        if(image ~ /fit/){
            class = "half-image-fit"
        } else {
            class = "half-image-cover"
        }
    } else if(image ~ /\[fit\]/){
        path = gensub(/!\[fit\]/, "", "g", image)
        position = "fit"
        class = "fit-image"
    } else {
        path = gensub(/!\[\]/, "", "g", image)
        position = "fit"
        class = "fit-image"
    }
    converted = "<div class='" class " " position"' style=\"background-image: url" path ";\">"
    close_div += 1
    image_list[0] = converted
    return reverse[position]
}


function handle(line){
    return handle_inlined(line)
}
function handle_inlined(line){
    if(line ~ /[_]+\w+[_]+/){
        return gensub(/([_]+)(\w+)([_]+)/, " \\1\\2\\3 \\4", "g", line)
    } else {
        return line
    }
}

function build_slide(    line){
    image_counter = 0
    # If we have more than one image in one slide, they are going to be in the
    # background and distributed. Any text should float to the center
    if(length(images) > 1){
        show_rule("Split images and center float", "no line")
        build_image_split(images)
        float = "center"
    }
    # If we only have one image, it can be on either side or fit.
    # Text should float to _the other side_
    if(length(images) == 1){
        show_rule("Lone image", "no line")
        float = build_image(images)
    }
    # If we have no images, we need to switch to table mode and open a cell, and mark
    # these divs as needing closure
    if(length(images) == 0){
        show_rule("No images", "no line")
        print ""
        print "::: full"
        print ""
        print ""
        print "::: cell"
        print ""
        close_tc += 2
    }

    for (i in current_content) {
        # A new line is either empty, an image placeholder or floating text
        line = current_content[i]
        # logg("==> " line)
        if (line == "image_placeholder"){
            image = images[image_counter]
            show_rule("Replacing placeholder by image", image)
            print image
            image_counter += 1
        } else if (line != "" && float == "center"){
            # Two types of floats: in front of multi-split background images or
            # just floating in front of a fit background image
            if(image_counter > 1){
                show_rule("Nonempty line, with images, float to center", line)
                print "::: centered-float"
                close_tc += 1
            } else if(normal_lines > 0){
                show_rule("Nonempty line, not aside, float to center", line)
                print "::: full"
                print ""
                print "::: cell"
                print ""
                close_tc += 2
            }
            float = "none"
            print handle(line)
        } else if (line != "" && float != "none" && float != "center"){
            show_rule("Nonempty line, float to either side", line)
            if(close_div > 0){
                print "</div>"
                print ""
                close_div -= 1
            }
            print "::: " float "-float"
            print ""
            print "::: cell"
            print ""
            float = "none"
            close_tc += 2
            print handle(line)
        } else {
            show_rule("No specific rule, pass through", line)
            print handle(line)
        }
    }
    # Finally we need to clean all the global counters
    reset_counters()
}

function push(item, array){
    len = length(array)
    array[len] = item
}

function close_slide(){
    if(close_aside == 1){
        print "</aside>"
        print ""
        close_aside = 0
    }
    while(close_tc > 0){
        print ""
        print ":::"
        print ""
        close_tc -= 1
    }
    while(close_div > 0){
        print "</div>"
        print ""
        close_div -= 1
    }
}

function show_rule(name, line){
    if(show_rules==1){
        logg("Rule " green(name) " applied to '" amber(line) "'")
    }
}

function parser(line){
    if(line == "---"){
        build_slide()
        close_slide()
        print line
        print ""
        show_rule("build and close slide", line)
    } else if(line ~ /!\[/){
        # Lines are either an image (images get moved to an image array),
        push(line, images)
        push("image_placeholder", current_content)
        show_rule("is image", line)
    } else if (line ~ /^# /) {
        # A special case is handled here: pandoc treats h1
        # as a new slide, and we don't want that here, so we modify all h1
        # to be h2
        push("#" line, current_content)
        normal_lines += 1
        show_rule("is h1", line)
    } else if (line ~ /^\^/) {
        # speaker notes
        push("<aside class='notes'>" line, current_content)
        close_aside = 1
        show_rule("is speaker note", line)
    } else if (line ~ /^\[.build-lists: true\]$/) {
        # or possibly instructions (like build-lists) for
        # presentation,
        push("::: incremental", current_content)
        close_tc = +1
    }
    else {
        if (line !~ /^\s+$/ && line !~ /^$/){
            # or just a plain old line.
            show_rule("is just a nonempty line", line)
            push(line, current_content)
            normal_lines += 1
        } else {
            show_rule("This is a skip line", line)
            push(line, current_content)
        }
    }
}

{
    # Main loop. Parses each line, processes slides completely.
    line = $0
    parser(line)
}
