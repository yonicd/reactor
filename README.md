
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactor

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

When developing Shiny apps there is a lot of reactivity problems that
can arise when one `reactive` or `observe` element triggers other
elements. In some cases these can create cascading reactivity (the
horror). The goal of `reactor` is to diagnose these reactivity problems
and then plan unit tests to avert them during development to make
development less painful.

![](https://github.com/yonicd/reactor/raw/media/example.gif)

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

In this app the plot is only rendered when the `input$n` is updated.

  - We expect the reactive element that creates the plot to be
    invalidated only once.

<details open>

<summary> <span title="Click to Expand"> Good App Script </span>
</summary>

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
  
  shiny::observeEvent(input$n,{  # <----- run only when input$n is invalidated
    output$plot <- shiny::renderPlot({
      whereami::whereami(tag = 'hist')
      graphics::hist(stats::runif(input$n))
    })
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
```

</details>

<br>

### Bad App

In this app the plot is rendered every time reactive elements in `input`
are invalidated.

  - This kind of setup can cause a lot of unwanted reactivity in larger
    apps with many elements.
  - We expect the reactive element that creates the plot to be
    invalidated more than once.

<details open>

<summary> <span title="Click to Expand"> Bad App Script </span>
</summary>

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
  
  shiny::observe({ # <----- run every time any element in input is invalidated
    output$plot <- shiny::renderPlot({
      whereami::whereami(tag = 'hist')
      graphics::hist(stats::runif(input$n))
    })
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
```

</details>

<br>

### Testing

Using `reactor` we can test this expectation\!

If we run the test on the `good app` the test will pass and if we run it
on the `bad app` then it will fail signaling a problem.

<details closed>

<summary> <span title="Click to Expand"> Good Reactivity Test Script
</span> </summary>

``` r

testthat::context("good reactivity")

testthat::describe('reactive',{
  
  testthat::skip_on_cran()
  
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
    appDir = system.file('examples/good_app.R',package = 'reactor')
  )
  )
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(hist_counter, tag = 'hist', 1)
  })
  
})
```

</details>

<br>

<details closed>

<summary> <span title="Click to Expand"> Bad Reactivity Test Script
</span> </summary>

``` r

testthat::context("bad reactivity")

testthat::describe('reactive',{
  
  testthat::skip('bad test')
  
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
    reactor::expect_reactivity(hist_counter, tag = 'hist', 1)
  })
  
})
```

</details>

<br>
