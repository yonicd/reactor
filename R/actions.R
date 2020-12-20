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
#' @rdname execute
#' @export
execute <- function(obj,expr){
  wait_for_shiny(obj)
  obj$test_driver$client$executeScript(expr)
  wait_for_shiny(obj)
  invisible(obj)
}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param obj PARAM_DESCRIPTION
#' @param command PARAM_DESCRIPTION
#' @param id PARAM_DESCRIPTION
#' @param flatten logical, flatten the output list. Default: FALSE
#' @param include_clientdata logical, include the client data in the output. Default: FALSE
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
query <- function(obj,command,flatten = FALSE){
  
  ret <- obj$test_driver$client$executeScript(glue::glue('return {command}'))
  
  if(flatten)
    ret <- unlist(ret,recursive = FALSE)
  
  ret
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
  execute(obj,glue::glue("$('#{id}').click()"))
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
  execute(obj,glue::glue("Shiny.setInputValue('{id}',{jsonlite::toJSON(value)});"))
}

#' @rdname query
#' @export
query_output_id <- function(obj,id){
  outputs <- query_outputs(obj)
  outputs[grepl(glue::glue('^{id}\\b'),names(outputs))]
}

#' @rdname query
#' @export
query_input_id <- function(obj,id){
  inputs <- query_inputs(obj)
  inputs[grepl(glue::glue('^{id}\\b'),names(inputs))]
}

#' @rdname query
#' @export
query_inputs <- function(obj, include_clientdata = FALSE){
  ret <- query(obj,glue::glue('Shiny.shinyapp.$inputValues'))
  
  if(!include_clientdata){
    ret <- ret[!grepl('^.clientdata',names(ret))]
  }
  
  ret
}

#' @rdname query
#' @export
query_outputs <- function(obj, include_clientdata = FALSE){
  ret <- query(obj,glue::glue('Shiny.shinyapp.$values'))
  
  if(!include_clientdata){
    ret <- ret[!grepl('^.clientdata',names(ret))]
  }
  
  ret
}

#' @rdname query
#' @export
query_input_names <- function(obj){
  names(query_inputs(obj))
}

#' @rdname query
#' @export
query_output_names <- function(obj){
  names(query_outputs(obj))
}
