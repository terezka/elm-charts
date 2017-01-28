# Elm Plot

Plot stuff in SVG with Elm!


## Overview

Currently, this library can draw scatter, line, bar and area-series, grids, hints, and as many axes as you could wish for with easily configurable ticks and labels. I'm still working on catching up with common features of the plotting libraries already around, and the API might change, so please bear with me!

![alt tag](https://raw.githubusercontent.com/terezka/elm-plot/master/example.png)


### What does the api look like?

Something like this:

```elm
    main =
		plot
			[ size plotSize
			, margin ( 10, 20, 40, 20 )
			]
			[ line
			    [ Line.stroke pinkStroke
			    , Line.strokeWidth 2
			    ]
			    data
			, xAxis
			    [ Axis.line [ Line.stroke axisColor ]
			    , Axis.tick [ Tick.viewDynamic toTickStyle ]
			    , Axis.label [ Label.viewDynamic toLabelStyle ]
			    ]
			]
```

You're welcome to take a look at the docs folder for many more [examples](https://github.com/terezka/elm-plot/tree/master/docs)! 

### Missing something?

Let me know! Open an issue (or PR) or write at #elm-plot in the elm-lang's [slack](http://elmlang.herokuapp.com). Please don't hesistate - I'm happy to answer any questions or get any kind of feedback! ✨

## Development

### Setup

```elm
elm package install
elm-reactor
```

and open [docs](http://localhost:8000/docs/Docs.elm) (The docs contain a bunch of examples convenient for developing.)

### Compile the Docs

```
elm-make docs/Docs.elm --output=docs/docs.js
```

### Tests

Tests are written with [elm-test](https://github.com/elm-community/elm-test).
For further information on elm-test, check the documentation.
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
