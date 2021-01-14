#' @title Execute Command in Application
#' @description Execute JavaScript function in application.
#' @param obj reactor object
#' @param expr character, Javascript command
#' @return reactor object
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname execute
#' @family actions
#' @export
execute <- function(obj,expr){
  wait_for_shiny(obj, maxiter = obj$maxiter, log_time = FALSE)
  obj$test_driver$client$executeScript(expr)
  wait_for_shiny(obj, maxiter = obj$maxiter)
  invisible(obj)
}

#' @title Query Command in Application
#' @description Send a query to the application and return a value.
#' @param obj reactor object
#' @param command character, JavaScript command
#' @param id character, id of the element
#' @param style name of the style element
#' @param flatten logical, flatten the output list. Default: FALSE
#' @param include_clientdata logical, include the client data in the output. Default: FALSE
#' @return value returned by the query
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
#' @family actions
#' @export 
#' @importFrom glue glue
query <- function(obj,command,flatten = FALSE){
  
  ret <- obj$test_driver$client$executeScript(glue::glue('return {command}'))
  
  if(flatten)
    ret <- unlist(ret,recursive = FALSE)
  
  ret
}

#' @title Click an element
#' @description Send a click command to an element in the application.
#' @param obj reactor object
#' @param id character, id of the element
#' @return reactor object
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
#' @family actions
#' @export 
#' @importFrom glue glue
click_id <- function(obj,id){
  execute(obj,glue::glue("$('#{id}').click()"))
}

#' @title Set the value of an element
#' @description Set the value of an element by element id.
#' @param obj reactor object
#' @param id character, id of the element
#' @param value value to set the element to
#' @return reactor object
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
#' @family actions
#' @export 
#' @importFrom glue glue
set_id_value <- function(obj,id,value){
  execute(obj,glue::glue("Shiny.setInputValue('{id}',{jsonlite::toJSON(value)});"))
}

#' @rdname query
#' @export 
#' @importFrom glue glue
query_style_id <- function(obj,id,style,flatten = FALSE){

  query(
    obj,
    glue::glue("document.querySelector('#{id}').style.{style}"),
    flatten = flatten
  )
  
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
