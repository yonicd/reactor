testthat::context("testing reactivity on a bad app with reactor")

# We now run the same test but with the "bad" app  

obj <- init_reactor()%>%
  set_chrome_driver(
    chromever = '88.0.4324.27'
  )

testthat::describe('bad reactive',{

  it('reactive hits in plot reactive chunk',{
    obj%>%
      set_runapp_args(
        appDir = system.file('examples/bad_app.R',
                             package = 'reactor')
      )%>%
      start_reactor()%>%
      set_id_value('n',500)%>%
      expect_reactivity(tag = 'hist',count =  2)%>%
      kill_app()
  })

})
