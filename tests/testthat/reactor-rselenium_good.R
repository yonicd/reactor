testthat::context("testing reactivity on a good app with reactor")

obj <- init_reactor()%>%
  set_chrome_driver(
    chromever = chrome_version()
  )

# We run a test with the expectation that the hist tag 
# will be triggered once at app startup and once after 
# input$n is updated

testthat::describe('good reactive',{

  it('reactive hits in plot reactive chunk',{
    obj%>%
      set_runapp_args(
        appDir = system.file('examples/good_app.R',
                             package = 'reactor')
      )%>%
      start_reactor()%>%
      set_id_value('n',500)%>%
      expect_reactivity(tag = 'hist',count =  2)%>%
      kill_app()
  })
  
})
