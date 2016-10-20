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
