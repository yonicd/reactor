testthat::context("testing reactivity on a good app")


driver_commands <- quote({
  
  # wait for input$n element to be created
  el_n <- reactor::asyncr(test_driver,using = 'id',value = 'n')
  
  # collect img src of histogram
  hist_src <- reactor::asyncr(
    test_driver,
    using = 'css',
    value = '#plot > img',
    attrib = 'src')
  
  # stepUp input$n by 4
  test_driver$client$executeScript(script = 'arguments[0].stepUp(4);',args = list(el_n))
  
  # wait for the histogram img src to update
  reactor::asyncr_update(test_driver,
                         using = 'css',
                         value = '#plot > img',
                         attrib = 'src',
                         old_value = hist_src)
  
})

# We run a test with the expectation that the hist tag will be triggered once.

testthat::describe('good reactive',{
  
  testthat::skip_if_not(interactive())
  
  hist_counter <- reactor::test_reactor(
    expr          = driver_commands,
    test_driver   = reactor::driver(), #selenium driver
    processx_args = runApp_args(
      appDir = system.file('examples/good_app.R',package = 'reactor')
    )
  )
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(hist_counter, tag = 'hist', 1)
  })
  
})

# We now run the same test but with the "bad" app  
  
testthat::context("testing reactivity on a bad app")

testthat::describe('bad reactive',{
  
  testthat::skip_if_not(interactive())
  
  hist_counter <- reactor::test_reactor(
    expr          = driver_commands,
    test_driver   = reactor::driver(), #selenium driver
    processx_args = reactor::runApp_args(
      appDir = system.file('examples/bad_app.R',package = 'reactor')
    )
  )
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(hist_counter, tag = 'hist', 1)
  })
  
})