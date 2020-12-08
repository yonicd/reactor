#' @title Reactor testing Environment
#' @description Environment which sets up and runs Shiny App tests.
#' @param expr expressions that drive the application
#' @param test_path character, path to run the test in. Default: tempdir()
#' @param test_ip character, IP address to run the App. Default: 'http://127.0.0.1'
#' @param test_port numeric, port to run the App. Default: 6012
#' @param test_driver [remoteDriver][RSelenium::remoteDriver], Default: firefox_driver(test_path = test_path)
#' @param processx_args list, arguments to pass to temporary session that serves the App. Default: runApp_args(test_ip, test_path)
#' @param processx_cleanup logical, cleanup the artifacts created by processx. Default: TRUE
#' @return whereami counter data.frame
#' @examples 
#' \dontrun{
#' if(interactive()){
#' 
#' driver_commands <- quote({
#' 
#' # wait for input$n element to be created
#' el_n <- reactor::wait(
#' test_driver = test_driver,
#' expr = test_driver$client$findElement(using = 'id', value = 'n')
#' )
#' 
#' # Set input$n to 500
#' test_driver$client$executeScript(script = 'Shiny.setInputValue("n","500");')
#' 
#' })
#' 
#' hist_counter_good <- reactor::test_reactor(
#' expr          = driver_commands,
#' test_driver   = reactor::firefox_driver(),
#' processx_args = reactor::runApp_args(
#' appDir = system.file('examples/good_app.R',package = 'reactor')
#' )
#' )
#' 
#' reactor::expect_reactivity(object = hist_counter_good, tag = 'hist',count =  2)
#' 
#' hist_counter_bad <- reactor::test_reactor(
#' expr          = driver_commands,
#' test_driver   = reactor::firefox_driver(),
#' processx_args = reactor::runApp_args(
#' appDir = system.file('examples/bad_app.R',package = 'reactor')
#' )
#' )
#' 
#' reactor::expect_reactivity(object = hist_counter_bad, tag = 'hist',count =  2)
#'  
#' }
#' 
#' @seealso 
#'  \code{\link[processx]{process}}
#' @rdname test_reactor
#' @export 
#' @importFrom processx process
#' @importFrom glue glue
#' @import whereami
test_reactor <- function(expr, 
                         test_path = tempdir(),
                         test_ip = 'http://127.0.0.1',
                         test_port = 6012,
                         test_driver = firefox_driver(test_path = test_path),
                         processx_args = runApp_args(test_port, test_path),
                         processx_cleanup = TRUE
                          ){
  
  on.exit({
    test_driver$client$closeall()
    test_driver$server$stop()
    x$kill()
    if(processx_cleanup)
      unlink(testdir,recursive = TRUE,force = TRUE)
  })
  
  testdir <- file.path(test_path,'reactor')
  dir.create(testdir,showWarnings = FALSE)
  
  # spawn child process for app
  x <- processx::process$new(
    command = normalizePath(file.path(Sys.getenv("R_HOME"),'R')), 
    args    = c("-e", paste0(processx_args,collapse = ';')),
    stderr  = file.path(testdir,'err.txt'),
    stdout  = file.path(testdir,'out.txt'))

  if(!x$is_alive()){
    read_stderr(test_path)
    stop('error in child process')
  }

  # navigate to app
  test_driver$client$navigate(glue::glue("{test_ip}:{test_port}"))
  
  # drive the app
  if(inherits(expr,'call')){
    eval(substitute(expr))  
  }else{
    eval(expr)
  }
  
  # wait for json log 
  file_timeout(file.path(testdir,'whereami.json'))
  
  # read json log
  Sys.sleep(0.3)
  read_reactor(testdir)

}
