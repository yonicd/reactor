testthat::context("testing reactivity")

driver_commands <- quote({
  
  # wait for input$n element to be created
  el_n <- test_driver%>%
    reactor::wait(
      expr = test_driver$client$findElement(using = 'id', value = 'n')
    )
  
  # collect img src of histogram
  hist_src <-test_driver%>%
    reactor::wait(
      expr = test_driver$client$findElement(using = 'css', value = '#plot > img')
    )%>%
    reactor::then(
      expr = function(elem) elem$getElementAttribute('src')[[1]],
      test_driver = test_driver
    )
    
  # stepUp input$n by 4
  test_driver$client$executeScript(script = 'arguments[0].stepUp(4);',args = list(el_n))
  
  #wait for the histogram img src to update
  
  test_driver%>%
    reactor::wait(
      expr   = test_driver$client$findElement(using = 'css', value = '#plot > img')
    )%>%
    reactor::then2(
      elem2 = hist_src,
      expr   = function(elem,elem2){
       
      elem$getElementAttribute('src')[[1]]%>%
        is_identical(elem2)
         
      },
      test_driver = test_driver
    )
  
})

testthat::context("testing reactivity on a good app")

# We run a test with the expectation that the hist tag will be triggered once.

testthat::describe('good reactive',{
  
  testthat::skip_if_not(interactive())
  
  hist_counter <- reactor::test_reactor(
    expr          = driver_commands,
    test_driver   = reactor::firefox_driver(),
    processx_args = reactor::runApp_args(
      appDir = system.file('examples/good_app.R',package = 'reactor')
    )
  )
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(object = hist_counter, tag = 'hist',count =  1)
  })
  
})

# We now run the same test but with the "bad" app  
  
testthat::context("testing reactivity on a bad app")

testthat::describe('bad reactive',{
  
  testthat::skip_if_not(interactive())
  
  hist_counter <- reactor::test_reactor(
    expr          = driver_commands,
    test_driver   = reactor::firefox_driver(), #selenium driver
    processx_args = reactor::runApp_args(
      appDir = system.file('examples/bad_app.R',package = 'reactor')
    )
  )
  
  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(hist_counter, tag = 'hist', 1)
  })
  
})