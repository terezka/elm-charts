# Elm Plot

Plot stuff in SVG with Elm!

## Overview

So, in the spirit of Elm and its goal of not only being a tool to express yourself elegantly,
but also help you do so, this library tried to guide you towards nice plots. Of course, it's not only my
own preferences, but also a guy called [Edward Tufte](https://en.wikipedia.org/wiki/Edward_Tufte) who wrote
the book [The Visual Display of Quantitative Information](https://www.edwardtufte.com/tufte/books_vdqi) and had a
lot of great ideas of how to make plots more readable. However, if you find that these restrictions are keeping you
from doing something incredible vital, then lets talk about it and see if it makes sense to allow it.

### What does the api look like?

Something like this:

```elm
    main =
      viewSeries
        [ area (List.map (\{ x, y } -> circle x y)) ]
        [ { x = 0, y = 1 }
        , { x = 2, y = 2 }
        , { x = 3, y = 3 }
        , { x = 4, y = 5 }
        , { x = 5, y = 8 }
        ]
```

You're welcome to take a look at the docs folder for more [exampels](https://github.com/terezka/elm-plot/tree/master/docs)!

### Missing something?

Let me know! Open an issue (or PR) or write at #elm-plot in the elm-lang's [slack](http://elmlang.herokuapp.com). Please don't hesitate, I'm happy to answer any questions or receive feedback! 💛

## Development

### Setup

```elm
elm package install
elm-reactor
```

and open [docs](http://localhost:8000/docs/Docs.elm) (The docs contain a bunch of examples convenient for developing).

### Compile the Docs

```
elm-make docs/Docs.elm --output=docs/docs.js
```

### Tests

Tests are written with [elm-test](https://github.com/elm-community/elm-test).
For further information on elm-test check the documentation.
All required dependencies are downloaded and installed when initially running the command.

```
elm-test
```

## Release log

### 4.1.0
- Fixed bug with plot crashing if range is zero.
- Allow area and bar series to have a domain lowest above zero.
- Add bezier smoothing feature to lines and areas. :dizzy: Thanks, @mathiasbaert!
- Fix typos in docs. Thanks, @Mingan!
