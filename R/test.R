#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_driver PARAM_DESCRIPTION, Default: driver(test_path = test_path)
#' @param processx_args PARAM_DESCRIPTION, Default: runApp_args(test_ip, test_path)
#' @param processx_cleanup PARAM_DESCRIPTION, Default: TRUE
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[processx]{process}}
#' @rdname test_reactor
#' @export 
#' @importFrom processx process
#' @importFrom glue glue
#' @import whereami
test_reactor <- function(expr, 
                         test_path = tempdir(),
                         test_ip = 6012,
                         test_driver = driver(test_path = test_path),
                         processx_args = runApp_args(test_ip, test_path),
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
  test_driver$client$navigate(glue::glue("http://127.0.0.1:{test_ip}"))
  
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
