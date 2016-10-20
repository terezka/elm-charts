# elm-plot

Plot series in Svgs! Right now it can draw lines and areas. _In active development!_

![alt tag](https://raw.githubusercontent.com/terezka/elm-plot/master/plot-example1.png)


## What does the api look like?

```
Plot.plot
    [ Plot.dimensions (800, 500) ]
    [ Plot.area [ Plot.stroke "cornflowerblue", Plot.fill "#ccdeff" ] areaData
    , Plot.line [ Plot.stroke "mediumvioletred" ] lineData
    , Plot.xAxis [ Plot.viewTick myCustomTick ]
    , Plot.yAxis [ Plot.amountOfTicks 5 ]
    ]
```

The api is inspired by the elm-html attributes to create a more flexible configuration, allowing you
to pass down only your needs changing the default configuration. 

Also, in my experience, what you would really like from a plotting library is the calculations
of the positions and so on, not really the styling. Base on this, I've allowed your to pass down a function producing
the svg html to use for e.g. the tick (see `myCustomTick` in [the example](https://github.com/terezka/elm-plot/blob/master/examples/PlotExample.elm)). There is of course a default as well!

## Development

### Setup

```
elm package install
```

### Run

```
elm-reactor
```

and open [example](http://localhost:8000/examples/PlotExample.elm)
