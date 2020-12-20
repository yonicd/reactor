#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION

#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname init_reactor
#' @importFrom whereami counter_names
#' @export 
init_reactor <- function(){
  ret <- list(
    processx = NULL,
    driver   = NULL
  )
  # force import of whereami
  whereami::counter_names() 
  structure(ret,class = 'reactor')
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION

#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[pagedown]{find_chrome}}
#' @rdname chrome_version
#' @export 
#' @importFrom pagedown find_chrome
chrome_version <- function(){
  gsub('[^0-9.]','',system2(pagedown::find_chrome(),args = '--version',stdout = TRUE))
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param ... PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[yaml]{as.yaml}}
#' @rdname print.reactor
#' @export 
#' @importFrom yaml as.yaml
print.reactor <- function(x,...){
  x_print <- x[grep('^(processx|driver)$',names(x))]
  cat(yaml::as.yaml(list(reactor = x_print)))
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param silent PARAM_DESCRIPTION
#' @param processx_cleanup PARAM_DESCRIPTION, Default: TRUE
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[processx]{process}}
#' @rdname start_reactor
#' @export 
#' @importFrom processx process
start_reactor <- function(obj, silent = FALSE, processx_cleanup = TRUE){
  
  driver_name <- names(obj$driver)
  process_name <- names(obj$processx)
  
  driver_fun <- get(sprintf('%s_driver',driver_name),
                    envir = asNamespace('reactor'))
  
  process_fun <- get(sprintf('%s_args',process_name),
                     envir = asNamespace('reactor'))
  
  obj$test_driver <- do.call(driver_fun,obj$driver[[driver_name]])
  obj$process <- do.call(process_fun,obj$processx[[process_name]])
  
  test_path <- obj$processx[[process_name]]$test_path
  test_port <- obj$processx[[process_name]]$test_port
  
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
  
  obj <- navigate_to_app(obj,silent)
  
  invisible(wait_for_shiny(obj))

}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[glue]{glue}}
#' @rdname navigate_to_app
#' @export 
#' @importFrom glue glue
navigate_to_app <- function(obj,silent = FALSE){
  port <- obj$processx[[1]]$test_port
  ip <- obj$processx[[1]]$test_ip
  obj <- rachet(obj,ip,port,silent)
  obj <- set_timeout(obj)
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param processx_cleanup logical, cleanup the side effects created by processx. Default: TRUE
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname kill_app
#' @export 
kill_app <- function(obj, processx_cleanup = TRUE){
  
  obj$test_driver$client$closeall()
  obj$test_driver$server$stop()
  obj$test_process$kill()
  
  obj$test_process <- NULL
  obj$test_driver <- NULL
  
  if(processx_cleanup){
    test_dir <- file.path(obj$processx[[1]]$test_path,'reactor')
    unlink(test_dir,recursive = TRUE,force = TRUE)
  }
  
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param maxiter PARAM_DESCRIPTION, Default: 20
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname wait_for_shiny
#' @export 
wait_for_shiny <- function(obj,maxiter = 20){
  i <- 0
  DONE <- FALSE
  
  while (!DONE & (i <= maxiter)) {
    
    DONE <- !is_busy(obj)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1 
    
  }
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param milliseconds PARAM_DESCRIPTION, Default: 10000
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname set_timeout
#' @export 
set_timeout <- function(obj, milliseconds = 10000){
  timeouts(obj$test_driver$client, milliseconds = milliseconds)
  invisible(obj)
}

timeouts <- function (remDr, milliseconds){
  qpath <- sprintf("%s/session/%s/timeouts", remDr$serverURL,
                   remDr$sessionInfo[["id"]])
  remDr$queryRD(qpath, method = "POST", 
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