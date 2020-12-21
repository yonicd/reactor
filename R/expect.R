#' @title Expectation: is the counter equal to a value?
#' @description Compares the maximum counter value of a tag in a _whereami_ counter
#' object with a value
#' @param object a reactor class object or the path to whereami.json
#' @param tag character, tag name of the element in the counter object to query
#' @param count numeric, expected value
#' @return invisible result
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#' }
#' }
#' @rdname expect_reactivity
#' @family testing
#' @export
expect_reactivity <- function(object, tag, count) {
  UseMethod('expect_reactivity')
}

#' @importFrom testthat quasi_label expect
#' @importFrom rlang enquo
#' @export
expect_reactivity.default <- function(object, tag, count) {
  
  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")
  
  if(tag%in%object$tag){
    
    act$count <- max(object$count[object$tag==tag])  
    
  }else{
    
    act$count <- 0
    
  }
  
  testthat::expect(
    act$count == count,
    sprintf("The tag '%s' has reactivity count of %i, not %i.", tag, act$count, count)
  )
}

#' @export
expect_reactivity.reactor <- function(object, tag, count) {

  wait_for_shiny(object)
  
  wait_for_whereami(object)

  obj <- read_reactor(object)
  
  expect_reactivity(obj, tag, count)
  
  invisible(object)
}

wait_for_whereami <- function(obj, timeout = 0.3){
  
  whereami_json <- reactor_path(
    obj$processx[[1]]$test_path,
    'whereami.json'
  ) 
  
  if(file.exists(whereami_json)){
    #wait for log to update
    Sys.sleep(timeout)
    
  }else{
    #wait for log to update and to create the file
    Sys.sleep(timeout + 0.2)  
    
  }
  
}
