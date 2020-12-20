testthat::context("testing reactivity on a bad app with crrry")

# We now run the same test but with the "bad" app  

testthat::describe('bad reactive',{

  test <- crrry::CrrryProc$new(
    chrome_bin = pagedown::find_chrome(),
    shiny_port = httpuv::randomPort(),
    chrome_port = httpuv::randomPort(),
    fun = "shiny::runApp(appDir = system.file('examples/bad_app.R',package = 'reactor'))",
    pre_launch_cmd = glue::glue("dir.create('{reactor_path()}');whereami::set_whereami_log('{reactor_path()}')")
  )
  
  test$wait_for_shiny_ready()
  test$shiny_set_input('n',900)
  test$wait_for_shiny_ready()
  hist_counter <- reactor::read_reactor()
  test$stop()

  it('reactive hits in plot reactive chunk',{
    reactor::expect_reactivity(hist_counter, tag = 'hist', 2)
  })

})
