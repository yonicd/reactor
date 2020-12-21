#' @title Arguments to pass to a Shiny App in a child process
#' @description 
#' 
#'   - runApp_args: Arguments that populate a [runApp][shiny::runApp] call 
#'   that will be run in a child process.
#' 
#'   - golem_args:  Arguments that populate an app run via the golem package. 
#'   
#' The command is appended predefined commands and sent to a [process][processx::process] object.
#' 
#' @param appDir The application to run. Should be one of the following (Default: getwd()):
#'   - A directory containing server.R, plus, either ui.R or a www directory 
#'   that contains the file index.html.
#'   - A directory containing app.R.
#'   - An .R file containing a Shiny application, ending with an expression that produces a Shiny app object.
#' @param package_name name of the golem package
#' @param test_port integer, port to run the app on. Default: httpuv::randomPort()
#' @param test_ip The IPv4 address that the application should listen on.
#' @param test_path character, Path the child process will have access to on the master, Default: tempdir()
#' @return character
#' @examples 
#' 
#' runApp_args()
#' 
#' golem_args()
#' 
#' @seealso [runApp][shiny::runApp], [process][processx::process]
#' @rdname app_args
#' @family application
#' @export 
#' @importFrom glue glue
#' @import shiny
#' @importFrom httpuv randomPort
runApp_args <- function(
  appDir = getwd(),
  test_port = httpuv::randomPort(),
  test_ip = getOption("shiny.host", "127.0.0.1"),
  test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("options('shiny.port'= {test_port},shiny.host='{test_ip}')"),
    glue::glue("shiny::runApp(appDir = '{appDir}')")
    )
}

#' @rdname app_args
#' @family application
#' @export 
#' @importFrom glue glue
#' @importFrom httpuv randomPort
golem_args <- function(package_name ='', 
                       test_port = httpuv::randomPort(),
                       test_ip = getOption('shiny.host','127.0.0.1'),
                       test_path = tempdir()){
  
  app_call <- "run_app()"
  
  if(nzchar(package_name)){
    app_call <- paste(package_name,app_call,sep = '::')  
  }

  shiny_opts <- glue::glue("options('shiny.port'= {test_port},shiny.host='{test_ip}')")
  
  c(reactor_args(test_path = test_path),shiny_opts,app_call)
  
}

reactor_args <- function(test_path = tempdir()){
  
  c("pkgload::load_all()",
    "library(whereami)",
    glue::glue("whereami::set_whereami_log('{file.path(test_path,'reactor')}')")
  )
  
}

#' @title Attach Commands for Shiny Application to Reactor
#' @description Attach commands for starting shiny application 
#' using runApp or golem commands to the reactor object.
#' @param obj reactor object
#' @inheritParams runApp_args
#' @return reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname set_app_args
#' @family application
#' @export 
#' @importFrom httpuv randomPort
set_runapp_args <- function(
  obj, 
  appDir = getwd(), 
  test_port = httpuv::randomPort(),
  test_path = tempdir(), 
  test_ip = getOption('shiny.host','127.0.0.1')){
  
  obj$processx <- list(
    runApp = list(
      test_port = test_port, 
      test_path = test_path, 
      test_ip = test_ip,
      appDir = appDir
    )
  )
  
  invisible(obj)
}

#' @rdname set_app_args
#' @family application
#' @export 
#' @importFrom httpuv randomPort
set_golem_args <- function(
  obj, 
  package_name ='', 
  test_port = httpuv::randomPort(),
  test_path = tempdir(), 
  test_ip = getOption('shiny.host','127.0.0.1')
  ){
  obj$processx <- list(
    golem = list(
      test_port = test_port, 
      test_path = test_path, 
      test_ip = test_ip,
      package = package_name
    )
  )
  
  invisible(obj)
}
