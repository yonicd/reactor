#' @title Read Child Process Side Effects 
#' @description Read files created by reactor in the test folder
#' @param x path to reactor temporary folder or a reactor class 
#'   object. Default: tempdir()
#' @return contents of the file
#' @rdname read_reactor
#' @export 
read_reactor <- function(x) {
  UseMethod('read_reactor')
}

#' @rdname read_reactor
#' @export 
read_stdout <- function(x) {
  UseMethod('read_stdout')
}

#' @rdname read_reactor
#' @export 
read_stderr <- function(x) {
  UseMethod('read_stderr')
}

read_text <- function(path){
  ret <- readLines(path)
  cat(ret,sep ='\n')
  invisible(ret)
}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION, Default: tempdir()
#' @param ... PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname reactor_path
#' @export
reactor_path <- function(x = tempdir(),...){
  file.path(x,'reactor',...)
}

verify_path <- function(x){
  normalizePath(x,mustWork = TRUE)
}

#' @export 
read_stderr.default <- function(x = tempdir()) {
  read_text(verify_path(reactor_path(x,'err.txt')))
}

#' @export 
read_stdout.default <- function(x = tempdir()) {
  read_text(verify_path(reactor_path(x,'out.txt')))
}

#' @export
#' @importFrom jsonlite read_json
read_reactor.default <- function(x = tempdir()) {
  jsonlite::read_json(
    verify_path(reactor_path(x,'whereami.json')),
    simplifyVector = TRUE
  )
}

#' @export 
read_stderr.reactor <- function(x) {
  path <- x$processx[[1]]$test_path
  read_stderr(path)
}

#' @export 
read_stdout.reactor <- function(x) {
  path <- x$processx[[1]]$test_path
  read_stdout(path)
}

#' @export
read_reactor.reactor <- function(x) {
  path <- x$processx[[1]]$test_path
  read_reactor(path)
}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname reset_counter
#' @export 
reset_counter <- function(obj){
  test_path <- obj$processx[[1]]$test_path
  file.create(file.path(test_path,'reactor','whereami.json'),showWarnings = FALSE)
  invisible(obj)
}
