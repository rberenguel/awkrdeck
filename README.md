# Reformatter for markdown presentations

Small Frawkenstein to convert presentations written for
[Deckset](https://www.deckset.com) to be compatible with conversion via
[pandoc](http://pandoc.org) and [reveal.js](http://revealjs.com) to HTML.

Note that this is customised for how I write my slides and the theme I use.
Caveat emptor.

An example:
- [Speeding up PySpark with Arrow (with this)](https://rberenguel.github.io/pyspark-arrow-pandas/pyspark.html#/)
- [Speeding up PySpark with Arrow (original, in Slideshare)](https://www.slideshare.net/rberenguel/speeding-up-pyspark-with-arrow)

## "Features"

- Looks similar _enough_ (I use the [Inter](https://rsms.me/inter/) font family
  instead of [Ostrich Sans](https://open-foundry.com/fonts/ostrich_sans_heavy))
- I didn't want to fight with CSS a lot, so, fixed sizes where needed (so, it
  will look like crap on phones)
- It _just_ works good enough to convert at least the presentation above,
  haven't tried with any others yet
- Expects some whitespace exatly where I put it in my markdown, and some is actually
  needed by `pandoc` `¯\_(ツ)_/¯`
- I don't recommend you use this, to be fair

## How does it work

It's just an ad-hoc parser for markdown, using full slides as "tokens". Since
getting the DOM/CSS to play along can be tricky, there are some parts of the
slide that need rewriting before being passed to `pandoc`. This makes the code
slightly convoluted.

The workflow is that the AWK parser converts markdown files with extension `.md`
into reprocessed files with extension `.md_2`, then `pandoc` uses these to
create an HTML page. The intermediate `.md_2` files are kept, and are human
readable, just some rehashing of the original presentation (useful to find
places where the parser is doing something `pandoc` doesn't like)

You can use `make verbose` to see the rules applied in the parsing/building, and
there is a set of example presentations (with image splits, images, floats, text
formatting) to see what is being done. You will need to serve them somehow
(`make serve` will start a Python 3 folder server, but you need Python 3 for
that)

## How to use it

Clone or download, add your markdown file to the folder where the `.awk` and
`makefile` files are and run `make`. You will need `gawk` for this, since I use
two exclusive features (includes and deleting arrays).

The current settings will use `reveal.js` from the web. If you want a fully
standalone version, you need to download `reveal.js` to a folder called
`reveal.js` (this is the default when you unzip their releases) and run `make
local`.

## Why? Why AWK?

- I _love_ using Deckset, but I miss having a shareable version where animated
  gifs play. Fixed.

- I have always felt [AWK](https://en.wikipedia.org/wiki/AWK) is underrated as a
  language. It is quick to write, readable and gets the job done pretty nicely.
  This is obviously not the cleanest AWK I have ever written, but it got the job
  done pretty fast. And if you are asking _tests_? I'm working on that.
