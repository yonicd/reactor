#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_driver PARAM_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param elem PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname promise
#' @export 
wait <- function(test_driver, expr, maxiter = 20) {
  
  rachet(test_driver = test_driver, e = expr, maxiter = maxiter)

}

#' @rdname promise
#' @export 
then <- function(elem, expr, test_driver, maxiter = 20) {
  
    rachet(test_driver = test_driver, e = expr, maxiter = maxiter)
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_driver PARAM_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param elem PARAM_DESCRIPTION
#' @param elem2 PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname promise2
#' @export 
then2 <- function(elem, elem2, expr, test_driver, maxiter = 20) {
  
    rachet(test_driver = test_driver, e = expr, maxiter = maxiter)
  
}


is_busy <- function(test_driver){
  
  test_driver$client$executeScript(
    script = "return document.querySelector('html').getAttribute('class')=='shiny-busy';"
  )[[1]]
  
}

#' @title Tests objects for Exact Quality
#' @description Wrapper on [identical][base::identical] that will return the 
#' value of y if TRUE, else NULL. This function is useful with [wait][reactor::wait]/[then][reactor::then]
#' @inheritParams base::identical
#' @param \dots arguments passed to [identical][base::identical]
#' @return value of __y__ if x and y are identical, else NULL
#' @seealso [wait][reactor::wait], [then][reactor::then], [identical][base::identical]
#' @export
is_identical <- function(x,y,...){
  if(identical(x,y,...)){
    y
  }else{
    NULL
  }
}

rachet <- function(test_driver, e, maxiter, cond = is.null){
  
  elem <- NULL
  
  i <- 0

  while (cond(elem) & (i <= maxiter)) {

  if(!is_busy(test_driver)){
    
  suppressWarnings({
    suppressMessages({
      elem <- tryCatch({
          if(inherits(e,'call')){
              eval(substitute(e),parent.frame())
          }else{
              eval(e,parent.frame())
          }
      },
      error = function(e) {
        NULL
      }
      )
    })
  })
    
  }
  
  Sys.sleep(0.02 * (i + 1))
    
  i <- i + 1
    
  }
  
  if (is.null(elem) && i >= maxiter) {
    # assuming this means timed out
    stop("servers failed, please check network connectivity and try again",
         call. = FALSE
    )
  }
  
  elem
}