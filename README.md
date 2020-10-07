
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactor <img src="https://github.com/yonicd/hex/raw/master/images/logos/reactor.png" align="right" class="logo"/>

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

When developing Shiny apps there is a lot of reactivity problems that
can arise when one `reactive` or `observe` element triggers other
elements. In some cases these can create cascading reactivity (the
horror). The goal of `reactor` is to diagnose these reactivity problems
and then plan unit tests to avert them during development to make
development less painful.

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

![](https://github.com/yonicd/reactor/raw/media/good_app.gif)

<details closed>

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
shinyApp(ui = ui, server = server,options = list(port=6012))
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
  - Notice how on the app initialization the chunk is rendered twice.

![](https://github.com/yonicd/reactor/raw/media/bad_app.gif)

<details closed>

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

To run a test you can use standard `testthat` functions like
`testthat::test_dir()`, or you can use a `reactor` function
`reactor::test_app()`.

To use `test_app` just name the test file `reactor-*.R` instead of
`test-*.R` this will have two benefits.

1.  `covr` will not pass the tests. This allows you to run the tests
    using `test_dir` which does have the necessary characteristics to
    run the tests.
2.  Allows the app tests to be isolated from the other unit tests thus
    allowing for `covr` and `testthat` to run on R CMD CHECK without
    needing to add `skip_*` into the app test files.

![](https://github.com/yonicd/reactor/raw/media/example.gif)

<details closed>

<summary> <span title="Click to Expand"> Reactivity Test Script </span>
</summary>

``` r

testthat::context("testing reactivity")

driver_commands <- quote({
  
  # wait for input$n element to be created
  el_n <- reactor::wait(
      test_driver = test_driver,
      expr = test_driver$client$findElement(using = 'id', value = 'n')
    )

  # Set input$n to 500
  test_driver$client$executeScript(script = 'Shiny.setInputValue("n","500");')
  
})

testthat::context("testing reactivity on a good app")

# We run a test with the expectation that the hist tag will be triggered once.

testthat::describe('good reactive',{

  hist_counter <- reactor::test_reactor(
    expr          = driver_commands,
    test_driver   = reactor::firefox_driver(),
    processx_args = reactor::runApp_args(
      appDir = system.file('examples/good_app.R',package = 'reactor')
    )
  )
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(object = hist_counter, tag = 'hist',count =  2)
  })
  
})

# We now run the same test but with the "bad" app  
  
testthat::context("testing reactivity on a bad app")

testthat::describe('bad reactive',{

  hist_counter <- reactor::test_reactor(
    expr          = driver_commands,
    test_driver   = reactor::firefox_driver(),
    processx_args = reactor::runApp_args(
      appDir = system.file('examples/bad_app.R',package = 'reactor')
    )
  )

  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(hist_counter, tag = 'hist', 2)
  })

})
```

</details>

<br>
