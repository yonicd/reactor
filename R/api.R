#' @title Initialize Reactor
#' @description Initialize the reactor object.
#' @return reactor object
#' @details The reactor object is initialized with two emtpy slots that
#' must be filled. 
#' - __application__: Specifications for the background process that will host the application
#' - __driver__: Specifications for the webdriver that will interact with the application in the background process
#' @examples 
#' init_reactor()
#' @rdname init_reactor
#' @family reactor
#' @export 
#' @importFrom whereami counter_names
init_reactor <- function(){
  ret <- list(
    application = NULL,
    driver   = NULL,
    maxiter = 20
  )
  # force import of whereami
  whereami::counter_names() 
  structure(ret,class = 'reactor')
}

#' @export 
#' @importFrom yaml as.yaml
print.reactor <- function(x,...){
  x_print <- x[grep('^(application|driver)$',names(x))]
  cat(yaml::as.yaml(list(reactor = x_print)))
}

#' @title Start the reactor
#' @description Using the populated elements of reactor you can start
#' the child sessions. 
#' @param obj reactor object
#' @param silent logical, start silently. Default: FALSE
#' @return reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[processx]{process}}
#' @rdname start_reactor
#' @family reactor
#' @export 
#' @importFrom processx process
start_reactor <- function(obj, silent = FALSE){
  
  driver_name <- names(obj$driver)
  process_name <- names(obj$application)
  
  driver_fun <- get(sprintf('%s_driver',driver_name),
                    envir = asNamespace('reactor'))
  
  process_fun <- get(sprintf('%s_args',process_name),
                     envir = asNamespace('reactor'))
  
  obj$test_driver <- do.call(driver_fun,obj$driver[[driver_name]])
  obj$process <- do.call(process_fun,obj$application[[process_name]])
  
  test_path <- obj$application[[process_name]]$test_path
  test_port <- obj$application[[process_name]]$test_port
  
  testdir <- file.path(test_path,'reactor')
  dir.create(testdir,showWarnings = FALSE)
  
  # spawn child process for app
  obj$test_process <- processx::process$new(
    command = normalizePath(file.path(Sys.getenv("R_HOME"),'R')), 
    args    = c("-e", paste0(obj$process,collapse = ';')),
    stderr  = file.path(testdir,'err.txt'),
    stdout  = file.path(testdir,'out.txt')
  )
  
  if(!obj$test_process$is_alive()){
    read_stderr(test_path)
    stop('error in child process')
  }
  obj$app_flag <- FALSE
  obj <- reset_busy_time(obj)
  obj <- navigate_to_app(obj,silent)
  
  invisible(wait_for_shiny(obj,maxiter = obj$maxiter))

}

#' @title Navigate to Application
#' @description Navigating to application after reactor startup.
#' @param obj reactor object
#' @param silent logical, start silently. Default: FALSE
#' @return obj reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[glue]{glue}}
#' @rdname navigate_to_app
#' @family reactor
#' @export 
#' @importFrom glue glue
navigate_to_app <- function(obj,silent = FALSE){
  port <- obj$application[[1]]$test_port
  ip <- obj$application[[1]]$test_ip
  obj <- rachet(obj,ip,port,silent)
  obj <- set_timeout(obj)
  invisible(obj)
}

#' @title Close reactor
#' @description Safely close a reactor session.
#' @param obj reactor object
#' @param application_cleanup logical, cleanup the side effects created by reactor. Default: TRUE
#' @return reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname kill_app
#' @family reactor
#' @export 
kill_app <- function(obj, application_cleanup = TRUE){
  
  obj$test_driver$client$closeall()
  obj$test_driver$server$stop()
  obj$test_process$kill()
  
  obj$test_process <- NULL
  obj$test_driver <- NULL
  
  if(application_cleanup){
    test_dir <- file.path(obj$application[[1]]$test_path,'reactor')
    unlink(test_dir,recursive = TRUE,force = TRUE)
  }
  
  invisible(obj)
}

#' @title Wait for shiny
#' @description Holds the system while shiny is invalidating.
#' @param obj reactor object
#' @param maxiter Number of iterations to wait for shiny, Default: 20
#' @param ... pass arguments to time logger.
#' @return reactor object
#' @details R side explicit timeout is defined as 0.02 * iteration number in seconds.
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname wait_for_shiny
#' @family reactor
#' @export 
wait_for_shiny <- function(obj, maxiter = 20, ...){
  i <- 0
  DONE <- FALSE
  
  while (!DONE & (i <= maxiter)) {
    
    DONE <- !is_busy(obj)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1 
    
  }
  
  time_logger(i,...)
  
  invisible(obj)
}

#' @title Set Implicit Timeout
#' @description Set the implicit timeout for the webdriver.
#' @param obj reactor object
#' @param milliseconds Time interval to wait in milliseconds, Default: 10000
#' @return obj reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname set_timeout
#' @family driver
#' @export 
set_timeout <- function(obj, milliseconds = 10000){
  timeouts(obj$test_driver$client, milliseconds = milliseconds)
  invisible(obj)
}

timeouts <- function (remDr, milliseconds){
  qpath <- sprintf("%s/session/%s/timeouts", remDr$serverURL,
                   remDr$sessionInfo[["id"]])
  remDr$queryRD(qpath, 
                method = "POST", 
                qdata = jsonlite::toJSON(
                  list(
                    type = "implicit", 
                    ms = milliseconds
                  ), 
                  auto_unbox = TRUE)
  )
}

is_busy <- function(obj){
  
  query(
    obj,"document.querySelector('html').getAttribute('class')=='shiny-busy'",
    flatten = TRUE)
  
}

is_empty <- function(obj){
  
  query(obj,"document.getElementsByTagName('head')[0].innerHTML==''",
        flatten = TRUE)
  
}

#' @title Shiny busy loggers
#' @description Query/Reset shiny busy loggers
#' @param obj reactor object
#' @param history logical, return all the logged times, 
#' or only the last logged time? Default: FALSE
#' @return numeric
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname busy_time
#' @family reactor
#' @export 

get_busy_time <- function(obj, history = FALSE){
  
  ret <- get('busy_time',envir = env)
  
  if(!history&length(ret)>0){
    ret <- ret[length(ret)]
  }
  
  ret
  
}

#' @rdname busy_time
#' @export
reset_busy_time <- function(obj){
  assign('busy_time',numeric(),envir = env)
  invisible(obj)
}
