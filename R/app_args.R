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
#' @param test_port numeric, port to run the app on, Default: 6012
#' Default: getOption("shiny.host", "127.0.0.1")
#' @param test_path character, Path the child process will have access
#'  to on the master, Default: tempdir()
#' @param appDir The application to run. Should be one of the following (Default: getwd()):
#'   - A directory containing server.R, plus, either ui.R or a www directory 
#'   that contains the file index.html.
#'   - A directory containing app.R.
#'   - An .R file containing a Shiny application, ending with an expression 
#'   that produces a Shiny app object.
#' @param host The IPv4 address that the application should listen on.
#' @param workerId Can generally be ignored. Exists to help some editions of Shiny Server Pro route requests to the correct process. Default: ""
#' @return character
#' @examples 
#' 
#' runApp_args()
#' 
#' golem_args()
#' 
#' @seealso [runApp][shiny::runApp], [process][processx::process]
#' @rdname runApp_args
#' @export 
#' @importFrom glue glue
#' @import shiny
runApp_args <- function(
  test_port = 6012,
  test_path = tempdir(), 
  appDir = getwd(),
  host = getOption("shiny.host", "127.0.0.1"),
  workerId = ""
  ){
  
  glue_args <- glue::glue(
    "appDir = '{appDir}'",
    "port = {test_port}L",
    "host = '{host}'",
    "test.mode = TRUE",
    "workerId = '{workerId}'",.sep = ', ')
  
  c(reactor_args(test_path = test_path),
    glue::glue("shiny::runApp({glue_args})")
    )
  
}

#' @rdname runApp_args
#' @export 
#' @importFrom glue glue
golem_args <- function(test_port = 6012,test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("options('shiny.port'= {test_port},shiny.host='0.0.0.0')"),
    "run_app()"
  )
  
}

reactor_args <- function(test_path = tempdir()){
  
  c("pkgload::load_all()",
    "library(whereami)",
    glue::glue("whereami::set_whereami_log('{file.path(test_path,'reactor')}')")
  )
  
}