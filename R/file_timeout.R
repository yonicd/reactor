#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param path PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname file_timeout
#' @export 

file_timeout <- function(path, maxiter = 20) {
  
  file_found <- FALSE
  
  i <- 0
  
  while (!file_found & (i <= maxiter)) {
    
    file_found <- file.exists(path)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  if (i >= maxiter) {
    # assuming this means timed out
    stop(glue::glue(
    "Could not find {path}, please check network connectivity and try again"
    ),call. = FALSE
    )
  }
  
}
