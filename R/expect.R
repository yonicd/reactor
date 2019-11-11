#' @title Expectation: is the counter equal to a value?
#' @description Compares the maximum counter value of a tag in a whereami counter
#' object with a value
#' @param object whereami counter object read from whereami.json
#' @param tag character, tag name of the element in the counter object to query
#' @param count numeric, expected value
#' @return invisible result
#' @examples 
#' if(interactive()){
#' 
#' txt <- "
#' whereami::cat_where(whereami::whereami(tag = 'reactor test'))
#' "
#'
#' whereami::set_whereami_log(tempdir())
#'
#' tf <- tempfile(fileext = '.R')
#'
#' cat(txt,file = tf)
#'
#' source(tf)
#' 
#' counter <- read_reactor(path = tempdir())
#' 
#' expect_reactivity(counter,'reactor test',1)
#' 
#' # clean up temp files
#' 
#' whereami::counter_reset()
#' unlink(tf)
#' unlink(reactor_dir, recursive = TRUE, force = TRUE)
#' 
#' }
#' 
#' @rdname expect_reactivity
#' @export 
#' @importFrom testthat quasi_label expect
#' @importFrom rlang enquo
expect_reactivity <- function(object, tag, count) {

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
  
  invisible(act$val)
}