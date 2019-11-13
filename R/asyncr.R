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

#' @title Reactor Then with two elements
#' @description Mutli element Then functions used by reactor to interact with applications.
#' @param test_driver RSelenium [driver][RSelenium::rsDriver] object
#' @param expr expression to run
#' @param elem element to pass to expr
#' @param elem2 element to pass to expr
#' @param maxiter numeric, maximum number of iterations to wait in the then2 call, Default: 20
#' @return value determined by expr return.
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