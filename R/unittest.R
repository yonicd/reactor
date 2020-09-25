#' @title Reactor Unit Testing
#' @description Run unit tests for shiny apps
#' @param path character, path to testing directory, Default: 'tests/testthat'
#' @param \dots arguments to pass to [test_dir][testthat::test_dir]
#' @return [test_dir][testthat::test_dir] output
#' @details reactor unit test files are like testthat test files, just the name is `reactor-*.R`, instead of
#' `test-*.R`
#' @seealso
#'  [test_dir][testthat::test_dir]
#' @rdname test_app
#' @export
#' @importFrom testthat test_dir
test_app <- function(path = 'tests/testthat',...){

  td <- file.path(path,'reactor')
  dir.create(td,recursive = TRUE,showWarnings = FALSE)
  on.exit(unlink(td,recursive = TRUE,force = TRUE),add = TRUE)
  invisible(sapply(list.files(path,pattern = '^reactor-',full.names = TRUE),function(x){
    file.copy(x,file.path(td,gsub('^reactor','test',basename(x))))
  }))
  testthat::test_dir(td,...)

}

