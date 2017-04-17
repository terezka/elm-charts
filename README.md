# Elm Plot

A library for plotting using SVG and Elm. You can take a look [here](https://terezka.github.io/elm-plot)!

## Philosophy

This library may differ slightly from common ones around in the way that it does
not only aim to provide tools to make whatever visualization you need, but also
guide you to make better visualizations. _Better_ is of course subjective, but
this library chooses to follow the school of [Edward Tufte](https://en.wikipedia.org/wiki/Edward_Tufte), 
author of the book [The Visual Display of Quantitative Information](https://www.edwardtufte.com/tufte/books_vdqi).
His ideas on ideal visualizations are well summarized by the following quote.

> Graphical excellence is that which gives to the viewer the greatest number of 
ideas in the shortest time with the least ink in the smallest space. - Edward Tufte

However, if you find that these opinions are keeping you from doing something 
incredibly vital, then let's [talk about it](https://elmlang.slack.com/messages/elm-plot) 
and see if it makes sense to allow it.

## Features

Currently the library has the following features:

   - Series
      - Plain and area series.
      - Interpolations include none (a scatter), linear, and monotone-x.
   - Horizontally stacked bar charts / histograms.
   - All plots have the option for customizable axis, ticks and labels.
   
## What is the API like?

Aiming to provide you with an easy start, the library has different levels of customizations.
At a very basic level it could look like this:

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

You're welcome to take a look at the `/docs` folder for more [examples](https://github.com/terezka/elm-plot/tree/master/docs/src)!

## Missing something?

Let me know! Open an issue (or PR) or write in [slack](https://elmlang.slack.com/messages/elm-plot). Please don't hesitate, I'm happy to answer any questions or receive feedback!

## Development

### Setup

```elm
elm package install
elm-reactor
```

and open [docs](https://terezka.github.io/elm-plot/) (The docs contain a bunch of examples convenient for developing).

### Compile the Docs

```
elm-live docs/src/Docs.elm --output=docs/docs.js
```

### Tests

Tests are written with [elm-test](https://github.com/elm-community/elm-test).
For further information on elm-test check the documentation.
All required dependencies are downloaded and installed when initially running the command.

```
elm-test
```
