#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
#' @param test_driver PARAM_DESCRIPTION, Default: driver(test_path = test_path)
#' @param processx_args PARAM_DESCRIPTION, Default: shinyAppFile_args(test_ip, test_path)
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
#' @rdname test_reactor
#' @export 
#' @importFrom processx process
#' @importFrom glue glue
#' @import whereami
test_reactor <- function(expr, 
                          test_path = tempdir(),
                          test_ip = 6012,
                          test_driver = driver(test_path = test_path),
                          processx_args = shinyAppFile_args(test_ip, test_path),
                          processx_cleanup = TRUE
                          ){
  
  on.exit({
    client$closeall()
    server$stop()
    x$kill()
    if(processx_cleanup)
      unlink(testdir,recursive = TRUE,force = TRUE)
  })
  
  testdir <- file.path(test_path,'reactor')
  dir.create(testdir,showWarnings = FALSE)
  
  # spawn child process for app
  x <- processx::process$new(
    command = "R", 
    args    = c("-e", paste0(processx_args,collapse = ';')),
    stderr  = file.path(testdir,'err.txt'),
    stdout  = file.path(testdir,'out.txt'))

  if(!x$is_alive()){
    read_stderr(test_path)
    stop('error in child process')
  }

  # headless driver (selenium)
  client <- test_driver$client
  server <- test_driver$server
  
  # navigate to app
  client$navigate(glue::glue("http://127.0.0.1:{test_ip}"))
  
  # drive the app
  eval(substitute(expr))
  
  # wait for json log 
  file_timeout(file.path(testdir,'whereami.json'))
  
  # read json log
  read_reactor(testdir)

}


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
