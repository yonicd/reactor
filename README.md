
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

## Simple App

### Good App

In this app the plot is only rendered when the `input$n` is updated. We
expect `whereami` to log only once reactivity on line 18.

``` r
library(whereami)

# Define the UI
ui <- shiny::bootstrapPage(
  shiny::uiOutput('ui_n'),
  shiny::plotOutput('plot')
)

# Define the server code
server <- function(input, output) {
  
  output$ui_n <- shiny::renderUI({
    shiny::numericInput('n', 'Number of obs', 200)
  })
  
  shiny::observeEvent(input$n,{
    output$plot <- shiny::renderPlot({
      whereami::whereami(tag = 'hist')
      graphics::hist(stats::runif(input$n))
    })
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
```

### Bad App

In this app the plot is only rendered when the `input$n` is updated. We
expect `whereami` to log more than once reactivity on line 18.

``` r
library(whereami)

# Define the UI
ui <- shiny::bootstrapPage(
  shiny::uiOutput('ui_n'),
  shiny::plotOutput('plot')
)

# Define the server code
server <- function(input, output) {
  
  output$ui_n <- shiny::renderUI({
    shiny::numericInput('n', 'Number of obs', 200)
  })
  
  shiny::observe({
    output$plot <- shiny::renderPlot({
      whereami::whereami(tag = 'hist')
      graphics::hist(stats::runif(input$n))
    })
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
```

### Testing

Now we can test this expectation\!

If we run the test on the good app the test will pass and if we run it
on the bad app then it will fail signaling a problem.

``` r
testthat::context("reactivity")

testthat::describe('reactive',{
  
hist_counter <- reactor::test_reactor({
  
  # wait for input$n element to be created
  el_n <- reactor::asyncr(client,using = 'id',value = 'n')
  
  # collect img src of histogram
  hist_src <- reactor::asyncr(
    client,
    using = 'css',
    value = '#plot > img',
    attrib = 'src')
  
  # stepUp input$n by 4
  client$executeScript(script = 'arguments[0].stepUp(4);',args = list(el_n))
  
  # wait for the histogram img src to update
  reactor::asyncr_update(client,
                         using = 'css',
                         value = '#plot > img',
                         attrib = 'src',
                         old_value = hist_src)

  },
  processx_args    = runApp_args(
    appDir = system.file('examples/bad_app.R',package = 'reactor')
  )
)

  it('reactive hits in plot reactive chunk',{
    reactor::expect_count(hist_counter, tag = 'hist', 1)
  })
  
})
```
