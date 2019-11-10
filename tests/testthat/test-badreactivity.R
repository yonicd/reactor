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