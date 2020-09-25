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
#' # wait for input$n element to be created
#' el_n <- test_driver%>%
#'   reactor::wait(
#'     expr = test_driver$client$findElement(using = 'id', value = 'n')
#'   )
#' 
#' # collect img src of histogram
#' hist_src <-test_driver%>%
#'   reactor::wait(
#'     expr = test_driver$client$findElement(using = 'css', value = '#plot > img')
#'  )%>%
#'   reactor::then(
#'     expr = function(elem) elem$getElementAttribute('src')[[1]],
#'     test_driver = test_driver
#'   )
#' 
#' # stepUp input$n by 4
#' test_driver$client$executeScript(script = 'arguments[0].stepUp(4);',args = list(el_n))
#' 
#' #wait for the histogram img src to update
#' 
#' test_driver%>%
#'   reactor::wait(
#'     expr   = test_driver$client$findElement(using = 'css', value = '#plot > img')
#'   )%>%
#'   reactor::then2(
#'     elem2 = hist_src,
#'     expr   = function(elem,elem2){
#'       
#'       elem$getElementAttribute('src')[[1]]%>%
#'         is_identical(elem2)
#'       
#'     },
#'     test_driver = test_driver
#'   )
#'
#' })
#'  
#'   hist_counter <- reactor::test_reactor(
#'        expr    = driver_commands,
#'        test_driver   = reactor::firefox_driver(),
#'        processx_args = runApp_args(
#'        appDir = system.file('examples/good_app.R',package = 'reactor')
#'        )
#'      )  
#' 
#' reactor::expect_reactivity(hist_counter, tag = 'hist', 1)
#' 
#' reactor::expect_reactivity(hist_counter, tag = 'hist', 2)
#'  
#' }}
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
    command = "R", 
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
  read_reactor(testdir)

}
