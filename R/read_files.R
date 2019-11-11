#' @title Read Child Process Side Effects 
#' @description Read files created by [test_reactor][reactor::test_reactor] in the test folder
#' @param path character, path to test folder, Default: file.path(tempdir(),'reactor')
#' @return contents of the file
#' @rdname read_reactor
#' @export 
read_stderr <- function(path = file.path(tempdir(),'reactor')) {
  ret <- readLines(file.path(path,'err.txt'))
  cat(ret,sep ='\n')
  invisible(ret)
  
}

#' @rdname read_reactor
#' @export 
read_stdout <- function(path = file.path(tempdir(),'reactor')) {
  ret <- readLines(file.path(path,'out.txt'))
  cat(ret,sep ='\n')
  invisible(ret)
}

#' @importFrom jsonlite read_json
#' @rdname read_reactor
#' @export 
read_reactor <- function(path = file.path(tempdir(),'reactor')) {
  jsonlite::read_json(file.path(path,'whereami.json'),
                      simplifyVector = TRUE)
}
