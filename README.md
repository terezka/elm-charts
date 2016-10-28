# elm-plot

Plot series in Svgs! Right now it can draw lines and areas. _In active development!_

![alt plot](https://raw.githubusercontent.com/terezka/elm-plot/master/example.png)

## What does the api look like?

```elm
	plot
        [ size ( 600, 250 ), padding ( 40, 60 ) ]
        [ verticalGrid [ gridTickList [ -30, 30, 70 ], gridStyle [ ( "stroke", "#e2e2e2" ) ] ]
        , area [ areaStyle [ ( "stroke", "#e6d7ce" ), ( "fill", "#feefe5" ) ] ] areaData
        , line [ lineStyle [ ( "stroke", "#b6c9ef" ) ] ] lineData
        , yAxis [ axisLineStyle [ ( "stroke", "#b9b9b9" ) ], stepSize 20, customViewLabel customLabelY ]
        , xAxis [ axisLineStyle [ ( "stroke", "#b9b9b9" ) ], customViewTick customTick, customViewLabel customLabelX ]
        ]
```

The api is inspired by the elm-html attributes to create a more flexible configuration, allowing you
to pass down only your needs changing the default configuration.

Also, in my experience, what you would really like from a plotting library is the calculations
of the positions and so on, not really the styling. Based on this, I've allowed you to pass down a function producing
the svg html to use for e.g. the tick (see `myCustomTick` in [the example](https://github.com/terezka/elm-plot/blob/master/examples/PlotExample.elm)). There is of course a default as well!

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
elm-make docs/Docs.elm --output=docs/index.html
```
