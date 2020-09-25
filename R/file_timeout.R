#' @title Timer for waiting for File
#' @description Wait for file to be creating in a local folder
#' @param path character, Path to look for file
#' @param maxiter numeric, maximum iteration to wait, Default: 20
#' @return logical
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
