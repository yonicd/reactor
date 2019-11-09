#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param test_path PARAM_DESCRIPTION, Default: tempdir()
#' @param test_driver PARAM_DESCRIPTION, Default: driver(test_path = test_path)
#' @param test_ip PARAM_DESCRIPTION, Default: 6012
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
#' @rdname test_whereami
#' @export 
#' @importFrom processx process
#' @importFrom glue glue
#' @importFrom jsonlite read_json
test_whereami <- function(expr, 
                          test_path = tempdir(),
                          test_driver = driver(test_path = test_path),
                          test_ip = 6012
                          ){
  
  on.exit({
    client$closeall()
    server$stop()
    x$kill()
    unlink(shiny_testdir,recursive = TRUE,force = TRUE)
  })
  
  shiny_testdir <- file.path(test_path,'whereami_test')
  dir.create(shiny_testdir,showWarnings = FALSE)
  
  # spawn child process for app
  x <- processx::process$new(
    command = "R", 
    args    = child_args(test_ip, shiny_testdir),
    stderr  = file.path(shiny_testdir,'err.txt'),
    stdout  = file.path(shiny_testdir,'out.txt'))

  # headless driver (selenium)
  client <- test_driver$client
  server <- test_driver$server
  
  # navigate to app
  client$navigate(glue::glue("http://127.0.0.1:{test_ip}"))
  
  # drive the app
  eval(substitute(expr))
  
  # wait for json log 
  file_timeout(file.path(shiny_testdir,'whereami.json'))
  
  # read json log
  jsonlite::read_json(
    path = file.path(shiny_testdir,'whereami.json'),
    simplifyVector = TRUE
  )

}


#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
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
chrome_options <- function(download_path = tempdir()){

  list(
    args  = c("--headless","--disable-gpu", "--window-size=1280,800"),
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
#' @param test_path PARAM_DESCRIPTION
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
driver <- function(test_path,
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

#' @import whereami
#' @importFrom glue glue
child_args <- function(test_ip,test_dir){
  
  cmds <- c(
    "pkgload::load_all()",
    "library(whereami)",
    glue::glue("whereami::set_whereami_log('{test_dir}')"),
    glue::glue("run_app(shiny_opts = list(port = {test_ip}L))")
  )
 
  c("-e", paste0(cmds,collapse = ';') )
  
}