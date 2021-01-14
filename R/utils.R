env <- new.env()
env$busy_time <- numeric()
globalVariables('log_time')

time_logger <- function(iter,...){

  list2env(list(...),envir = environment())
  
  if(exists('log_time')){
    if(!log_time){
      return(invisible(NULL))
    }  
  } 
  
  work_time <- sum(0.02 * (0:(iter-1) + 1))
  env$busy_time <- c(env$busy_time,work_time)
  
}

#' @title re-export magrittr pipe operators
#'
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @family utils
#' @export
NULL
