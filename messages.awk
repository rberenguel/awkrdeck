function logg(message){
    print message > "/dev/stderr"
}

function normal(message){
    return message "\033[0m"
}

function red(message){
    return colorify("red", message)
}

function amber(message){
    return colorify("amber", message)
}

function green(message){
    return colorify("green", message)
}

function colorify(color, message){
    if (color == "green")
        return normal("\033[32m" message);
    else if (color == "red")
        return normal("\033[31m" message);
    else if (color == "amber")
        return normal("\033[33m" message);
    else
        return message
}
