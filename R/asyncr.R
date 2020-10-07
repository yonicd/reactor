#' @title Reactor Promises
#' @description Wait and Then functions used by reactor to interact with applications.
#' @param test_driver RSelenium [driver][RSelenium::rsDriver] object
#' @param expr expression to run
#' @param elem element returned by wait function for then call.
#' @param maxiter numeric, maximum number of iterations for wait 
#' and then calls, Default: 20
#' @return value determined by expr return.
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
          if(inherits(e,'function')){
            e(get('elem',envir = parent.frame()))
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