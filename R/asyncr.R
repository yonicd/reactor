#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param client PARAM_DESCRIPTION
#' @param using PARAM_DESCRIPTION
#' @param value PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @param attrib PARAM_DESCRIPTION, Default: NULL
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
asyncr <- function(client, using, value, maxiter = 20, attrib = NULL) {
  
  elem <- NULL
  
  i <- 0

  while (is.null(elem) & (i <= maxiter)) {

    suppressMessages({
      elem <- tryCatch({
        client$findElement(using = using, value = value)
      },
      error = function(e) {
        NULL
      }
      )
    })
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  if (is.null(elem) && i >= maxiter) {
    # assuming this means timed out
    stop("servers failed, please check network connectivity and try again",
         call. = FALSE
    )
  }
  
  if(!is.null(attrib)){
    
    attr_out <- NULL
    
    i <- 0
    
    while (is.null(attr_out) & (i <= maxiter)) {
    
      attr_out <- tryCatch({
        elem$getElementAttribute(attrib)[[1]]
      },
      error = function(e) {
        NULL
      }
      )
    
      Sys.sleep(0.02 * (i + 1))
      
      i <- i + 1
    }
    
    attr_out
    
  }else{
    
    elem
    
  }
  
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param client PARAM_DESCRIPTION
#' @param using PARAM_DESCRIPTION
#' @param value PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @param attrib PARAM_DESCRIPTION
#' @param old_value PARAM_DESCRIPTION
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

asyncr_update <- function(client, using, value, maxiter = 20, attrib, old_value){
  
  if(is.null(old_value))
    return(NULL)
  
  elem_update <- FALSE
  
  i <- 1
  
  while (!elem_update & (i <= maxiter)) {
    
    new_value <- asyncr(client, 
                        using = using, 
                        value = value, 
                        maxiter = maxiter, 
                        attrib = attrib)
    
    elem_update <- identical(old_value, new_value)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  invisible(new_value)
}


is_busy <- function(client){
  
  client$executeScript(
    script = "return document.querySelector('html').getAttribute('class')=='shiny-busy';"
  )[[1]]
  
}