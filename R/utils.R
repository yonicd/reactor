#' @inherit magrittr::'%>%'
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @export
NULL

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param headless PARAM_DESCRIPTION, Default: TRUE
#' @param download_path PARAM_DESCRIPTION, Default: tempdir()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname chrome_options
#' @export
chrome_options <- function(headless = TRUE, download_path = tempdir()){
  
  cargs  = c("--disable-gpu", "--window-size=1280,800")
  
  if(headless)
    cargs <- c("--headless",cargs)
  
  list(
    args  = cargs,
    prefs = list(
      "profile.default_content_settings.popups" = 0L,
      "download.prompt_for_download" = FALSE,
      "download.directory_upgrade" = TRUE,
      "safebrowsing.enabled" = TRUE,
      "download.default_directory" = download_path
    )
  )
}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @param check PARAM_DESCRIPTION, Default: TRUE
#' @param verbose PARAM_DESCRIPTION, Default: FALSE
#' @param port PARAM_DESCRIPTION, Default: 4567
#' @param c_opts PARAM_DESCRIPTION, Default: chrome_options(download_path = test_path)
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[RSelenium]{rsDriver}}
#' @rdname driver
#' @export 
#' @importFrom RSelenium rsDriver
driver <- function(test_path = tempdir(),
                   check = TRUE,
                   verbose = FALSE, 
                   port = 4567L,
                   c_opts = chrome_options(download_path = test_path)){
  
  RSelenium::rsDriver(
    browser = "chrome",
    verbose = verbose,
    port = port,
    extraCapabilities = list(
      chromeOptions = c_opts
    ),
    check = check
  )
}

