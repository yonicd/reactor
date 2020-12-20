rachet <- function(obj,ip,port,silent = FALSE, time_vec = c(0.5,1,2,6,10)){
  i <- 1
  FLAG <- TRUE
  
  if(!silent){
    cat('\nAttempting to connect to app')
  }
  
  while (FLAG & (i <= length(time_vec))) {
    
      suppressWarnings({
        suppressMessages({
          FLAG <- tryCatch({
            obj$test_driver$client$navigate(glue::glue('http://{ip}:{port}'))
            if(!silent){
              cat('\n')
              print(glue::glue('Connected to app in {sum(time_vec[1:i])} seconds'))  
            }
            
            FALSE
          },
          error = function(e) {
            if(!silent){
              cat('.')
            }
            TRUE
          }
          )
        })
      })
    
    Sys.sleep(time_vec[i])
    
    i <- i + 1
    
  }
  
  if (FLAG && i >= length(time_vec[i])) {
    # assuming this means timed out
    stop("servers failed, please check network connectivity and try again",
         call. = FALSE
    )
  }
  
  invisible(obj)
}
