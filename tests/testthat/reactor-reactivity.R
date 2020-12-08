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
