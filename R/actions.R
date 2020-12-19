#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname execute_script
#' @export
execute_script <- function(obj,expr){
  wait_for_shiny(obj)
  obj$test_driver$client$executeScript(expr)
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param id PARAM_DESCRIPTION
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
#' @rdname click_id
#' @export 
#' @importFrom glue glue
click_id <- function(obj,id){
  wait_for_shiny(obj)
  obj$test_driver$client$executeScript(glue::glue("$('#{id}').click()"))
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param id PARAM_DESCRIPTION
#' @param value PARAM_DESCRIPTION
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
#' @rdname set_id_value
#' @export 
#' @importFrom glue glue
set_id_value <- function(obj,id,value){
  wait_for_shiny(obj)
  obj$test_driver$client$executeScript(glue::glue("Shiny.setInputValue('{id}',{jsonlite::toJSON(value)});"))
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param id PARAM_DESCRIPTION
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
#' @rdname query_verbatimText
#' @export 
#' @importFrom glue glue
query_verbatimText <- function(obj,id){
  wait_for_shiny(obj)
  query <- glue::glue('return $("#{id}").text()')
  obj$test_driver$client$executeScript(query)[[1]]
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param command PARAM_DESCRIPTION
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
#' @rdname query
#' @export 
#' @importFrom glue glue
query <- function(obj,command){
  obj$test_driver$client$executeScript(glue::glue('return {command}'))[[1]]
}
