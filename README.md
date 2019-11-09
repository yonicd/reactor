
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactor

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

When developing Shiny apps there is a lot of reactivity problems that
can arise, where one `reactive` or `observe` element causes other
elements to trigger. In some cases these can create cascasding
reactivity (the horror). Being able to diagnose these reactivity
problems and then plan unit tests to avert them during development is a
valuable tool to make development more efficient and reliable.

The goal of reactor is to work in tandem with
[whereami](https://yonicd.github.io/whereami/index.html) to create unit
testing for shiny reactivity.

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("yonicd/reactor")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(reactor)
```

Lets take an application written by @ColinFay using the
[golem](https://thinkr-open.github.io/golem/) package for a [tidy
tuesday](https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-04-02)
by @rfordatascience.

I forked the repository app
[here](https://github.com/yonicd/tidytuesday201942).

### Breadcrumbs

I Dropped in a few `whereami` calls in the server functions so that
every time the `go` button is hit and a plot is rendered whereami will
log it.

``` r
observeEvent( input$go , {
    
    whereami::whereami(tag = 'go') #<----- here
    
    x <- rlang::sym(input$x)
    
    if (type == "point"){
      y <- sym(input$y)
      color <- sym(input$color)
      r$plot <- ggplot(big_epa_cars, aes(!!x, !!y, color = !!color))  +
        geom_point()+ 
        scale_color_manual(
          values = color_values(
            1:length(unique(pull(big_epa_cars, !!color))), 
            palette = input$palette
          )
        )
      r$code <- sprintf(
        "ggplot(big_epa_cars, aes(%s, %s, color = %s)) + 
        geom_point() +
        scale_color_manual(
        values = color_values(
        1:length(unique(dplyr::pull(big_epa_cars, %s))),
        palette = '%s' 
        )
        )", 
        input$x, 
        input$y,  
        input$color, 
        input$color, 
        input$palette 
      )
    } 
    
  output$plot <- renderPlot({
    whereami::whereami(tag = 'plot') # <--- and here
    r$plot
  })
  
```

### Testing

I added a
[test](https://github.com/yonicd/tidytuesday201942/blob/master/tests/testthat/test-whereami.R)
to the tests directory and I am good to go.

What I want to test:

  - How many times is the plot UI rendered when I enter the app and
    after I press the `go` button once.

What is happening here?

  - `test_whereami` is a wrapper that:
      - A background process that runs the app via `processx`
      - An `RSelenium` drives the app on a localhost on a headless
        chrome driver.
      - Runs the expressions passed into `test_whereami` are the
        commands run
          - `asyncr` : waits for the element called for to be generated
            (or an attribute of it) before assigning it to the object.
          - `asyncr_update` : waits for the element called to change for
            a previous value before returning the new value.
      - Returns the contents of the whereami.json that was created while
        the app was running.
  - `expect_count` then compares the amount of reactive hits that
    whereami logged for each tag with the expected hit count.

<!-- end list -->

``` r
context("reactivity")

testthat::describe('reactive',{

  plot_counter <- reactor::test_whereami(expr = {
    
    #find geom point option
    
    elem1 <- reactor::asyncr(
      client, #<---- RSelenium driver client created with reactor::driver(test_path = test_path)
      using = "css selector",
      value = '#raw_data > div > ul > li:nth-child(1) > a'
    )
    
    #click geom point option
    elem1$clickElement()
    
    #what is the current plot img src?
    plot_src <- reactor::asyncr(
      client,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src'
    )
    
    #find go button
    go_btn <- reactor::asyncr(
      client,
      using = "css selector",
      value = '#dataviz_ui_1-go'
    )
    
    #click go button
    go_btn$clickElement()
    
    #wait for the plot to render and update the img src
    reactor::asyncr_update(
      client,
      using = "css selector",
      value = '#dataviz_ui_1-plot > img',
      attrib = 'src',
      old_value = plot_src
    )
    
  })
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_count(plot_counter, tag = 'plot', 2)
  })
  
  it('reactive hits of go tbn',{
    reactor::expect_count(plot_counter, tag = 'go', 1)
  })
    
})
```

### Test Results

``` r
> devtools::test()
Loading tidytuesday201942
Testing tidytuesday201942
✔ |  OK F W S | Context
✔ |   3       | golem tests [5.2 s]
✔ |   2       | reactivity [5.8 s]

══ Results ════════════════════════════════════════════════════════════════════
Duration: 11.1 s

OK:       5
Failed:   0
Warnings: 0
Skipped:  0
```
