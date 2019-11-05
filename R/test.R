#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param expr PARAM_DESCRIPTION
#' @param dirpath PARAM_DESCRIPTION, Default: tempdir()
#' @param check PARAM_DESCRIPTION,  Default: interactive()
#' @param verbose PARAM_DESCRIPTION,  Default: interactive()
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
#'  \code{\link[RSelenium]{rsDriver}}
#' @rdname test_whereami
#' @export 
#' @import whereami
#' @importFrom glue glue
#' @importFrom processx process
#' @importFrom wdman chrome
#' @importFrom RSelenium rsDriver
#' @importFrom jsonlite read_json
test_whereami <- function(expr, dirpath = tempdir(),check = interactive(), verbose = interactive()){
  
  on.exit({
    remDr$closeall()
    rD$server$stop()
    cDrv$stop()
    x$kill()
    unlink(shiny_testdir,recursive = TRUE,force = TRUE)
  })
  
  shiny_testdir <- file.path(dirpath,'whereami_test')
  shiny_err     <- file.path(shiny_testdir,'err.txt')
  shiny_out     <- file.path(shiny_testdir,'out.txt')
  shiny_where   <- file.path(shiny_testdir,'whereami.json')
  
  dir.create(shiny_testdir,showWarnings = FALSE)
  test_ip <- 6012
  
  shiny_cmds <- c(
    "pkgload::load_all()",
    "library(whereami)",
    glue::glue("whereami::set_whereami_log('{shiny_testdir}')"),
    glue::glue("run_app(shiny_opts = list(port = {test_ip}L))")
  )
  
  x <- processx::process$new(
    "R", c("-e", paste0(shiny_cmds,collapse = ';')),
    stderr = shiny_err,
    stdout = shiny_out)
  
  chrome_args <- c("--headless","--disable-gpu", "--window-size=1280,800")
  
  chrome_pref = list(
    "profile.default_content_settings.popups" = 0L,
    "download.prompt_for_download" = FALSE,
    "download.directory_upgrade" = TRUE,
    "safebrowsing.enabled" = TRUE,
    "download.default_directory" = dirpath
  )
  
  chrome_options <- list(args = chrome_args, prefs = chrome_pref)
  
  cDrv <- wdman::chrome(
    verbose = verbose,
    check = check
  )
  
  rD <- RSelenium::rsDriver(
    browser = "chrome",
    verbose = verbose,
    port = 4567L,
    extraCapabilities = list(
      chromeOptions = chrome_options
    ),
    check = check
  )
  
  remDr <- rD$client
  
  remDr$navigate(glue::glue("http://127.0.0.1:{test_ip}"))
  
  eval(substitute(expr))
  
  file_timeout(shiny_where)
  
  return(jsonlite::read_json(shiny_where,simplifyVector = TRUE))
  
}
