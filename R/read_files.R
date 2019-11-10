#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname read_reactor
#' @export 

read_stderr <- function(path = tempdir()) {
  cat(readLines(file.path(path,'reactor','err.txt')),sep ='\n')
}

#' @importFrom jsonlite read_json
#' @rdname read_reactor
read_json <- function(path = tempdir()) {
  jsonlite::read_json(file.path(path,'reactor','whereami.json'),
                      simplifyVector = TRUE)
}

#' @rdname read_reactor
read_stdout <- function(path = tempdir()) {
  cat(readLines(file.path(path,'reactor','out.txt')),sep = '\n')
}