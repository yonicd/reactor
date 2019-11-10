#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param object PARAM_DESCRIPTION
#' @param tag PARAM_DESCRIPTION
#' @param count PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname expect_reactivity expect
#' @export 
#' @importFrom testthat quasi_label 
expect_reactivity <- function(object, tag, count) {

  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")
  
  # 2. Call expect()
  act$count <- max(object$count[object$tag==tag])
  
  testthat::expect(
    act$count == count,
    sprintf("%s has reactivity count of %i, not %i.", tag, act$count, count)
  )
  
  # 3. Invisibly return the value
  invisible(act$val)
}