# elm-plot

Plot series in Svgs! Right now it can draw lines and areas.

## What does the api look like?

```elm
	plot
        [ size ( 600, 250 ), padding ( 0, 40 ) ]
        [ verticalGrid
            [ gridMirrorTicks
            , gridStyle [ ( "stroke", "blue" ) ]
            ]
        , horizontalGrid
            [ gridValues [ 10, 20, 30, 40 ]
            , gridStyle [ ( "stroke", "blue" ) ]
            ]
        , xAxis [ axisStyle [ ( "stroke", "grey" ) ] ]
        , line [ lineStyle [ ( "stroke", "red" ) ] ] data1
        , area [ areaStyle [ ( "fill", "deeppink" ) ] ] data2
        ]
```

## Development

### Setup

```elm
elm package install
```

### Run

```
elm-reactor
```

and open [example](http://localhost:8000/examples/PlotExample.elm)

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
