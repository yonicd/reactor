reactor_args <- function(test_path = tempdir()){
  
  c("pkgload::load_all()",
    "library(whereami)",
    glue::glue("whereami::set_whereami_log('{file.path(test_path,'reactor')}')")
  )
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname golem_args
#' @export 
#' @importFrom glue glue
golem_args <- function(test_ip = 6012,test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("run_app(shiny_opts = list(port = {test_ip}L))")
  )
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param server PARAM_DESCRIPTION
#' @param ui PARAM_DESCRIPTION
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname shinyApp_args
#' @export 
#' @importFrom glue glue
#' @import shiny
shinyApp_args <- function(server, ui, test_ip = 6012, test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("shiny::shinyApp(ui = {ui}, server = {server},options = list(port = {test_ip}L))")
  )
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param appDir PARAM_DESCRIPTION
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname shinyAppDir_args
#' @export 
#' @importFrom glue glue
#' @import shiny
shinyAppDir_args <- function(appDir, test_ip = 6012, test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("shiny::shinyAppDir(appDir = '{appDir}', options = list(port = {test_ip}L))")
  )
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param appFile PARAM_DESCRIPTION, Default: 'app.R'
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname shinyAppFile_args
#' @export 
#' @importFrom glue glue
#' @import shiny
shinyAppFile_args <- function(appFile = 'app.R', test_ip = 6012, test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("shiny::shinyAppFile(appFile = '{appFile}', options = list(port = {test_ip}L))")
  )
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param appDir PARAM_DESCRIPTION, Default: getwd()
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @param host PARAM_DESCRIPTION, Default: getOption("shiny.host", "127.0.0.1")
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname runApp_args
#' @export 
#' @importFrom glue glue
#' @import shiny
runApp_args <- function(appDir = getwd(), test_ip = 6012, test_path = tempdir(), host = getOption("shiny.host", "127.0.0.1")){
  
  c(reactor_args(test_path = test_path),
    glue::glue("shiny::runApp(appDir = '{appDir}', port = {test_ip}L, host = '{host}', test.mode = TRUE)")
  )
  
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname manual_args
#' @export 
#' @importFrom glue glue
manual_args <- function(expr,test_path = tempdir()){
  
  c(reactor_args(test_path = test_path),
    glue::glue("{expr}")
  )
  
}