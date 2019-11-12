#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_driver PARAM_DESCRIPTION
#' @param e PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname asyncr
#' @export 
# https://goo.gl/jFqKfS
asyncr <- function(test_driver, e, maxiter = 20) {
  
  rachet(test_driver = test_driver, e = e, maxiter = maxiter)

}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_driver PARAM_DESCRIPTION
#' @param e PARAM_DESCRIPTION
#' @param attrib PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname asyncr_attrib
#' @export 
# https://goo.gl/jFqKfS
asyncr_attrib <- function(test_driver, e, attrib, maxiter = 20) {
  
  elem <- rachet(test_driver = test_driver, e = e, maxiter = maxiter)

  attr_out <- rachet(test_driver = test_driver,
         e = quote({ elem$getElementAttribute(attrib)[[1]] }),
         maxiter = maxiter
  )
  
  attr_out

  
}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_driver PARAM_DESCRIPTION
#' @param e PARAM_DESCRIPTION
#' @param attrib PARAM_DESCRIPTION
#' @param old_attrib PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname asyncr_update
#' @export 

asyncr_update <- function(test_driver, e, attrib, old_attrib, maxiter = 20){
  
  if(is.null(old_attrib))
    return(NULL)
  
  elem_update <- FALSE
  
  i <- 1
  
  while (!elem_update & (i <= maxiter)) {
    
    new_value <- asyncr_attrib(test_driver, e = e, attrib = attrib,  maxiter = maxiter)
    
    elem_update <- identical(old_attrib, new_value)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  invisible(new_value)
}


is_busy <- function(test_driver){
  
  test_driver$client$executeScript(
    script = "return document.querySelector('html').getAttribute('class')=='shiny-busy';"
  )[[1]]
  
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