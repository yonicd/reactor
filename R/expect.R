#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param counter PARAM_DESCRIPTION
#' @param tag PARAM_DESCRIPTION
#' @param exptected PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[testthat]{equality-expectations}}
#' @rdname expect_count
#' @export 
#' @importFrom testthat expect_equal
expect_count <- function(counter,tag,exptected){
  
  testthat::expect_equal(
  max(counter$count[counter$tag==tag]),
  exptected
  )
  
}
