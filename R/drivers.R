#' @title Chrome Driver Options
#' @description Arguments and preferences to pass to chrome driver
#' @param cargs character arguments to pass to driver. 
#' @param headless logical, is the driver run in headless state. Default: TRUE
#' @param \dots additional preferences to add to driver.
#' @param download_path character, Path to save files to. Default: tempdir()
#' @return list
#' @details
#' By default the preferences are set to allow for local dowloading to a user defined path.
#' 
#'   - chrome: 
#'     - "profile.default_content_settings.popups" = 0L
#'     - download.prompt_for_download" = FALSE
#'     - download.directory_upgrade" = TRUE
#'     - safebrowsing.enabled" = TRUE
#'     - download.default_directory" = download_path
#'     
#'   - firefox:
#'     - 'browser.download.folderList' = 2
#'     - 'browser.download.lastDir' = download_path
#'     - 'browser.download.dir' = download_path
#' 
#' @examples 
#' chrome_options()
#' firefox_options()
#' 
#' @rdname driver_options
#' @export
chrome_options <- function(
  cargs = c("--disable-gpu", "--window-size=1280,800"), 
  headless = TRUE,...,download_path = tempdir()
  ){
  
  if(headless)
    cargs <- c("--headless",cargs)
  
  list(
    args  = cargs,
    prefs = list(
      "profile.default_content_settings.popups" = 0L,
      "download.prompt_for_download" = FALSE,
      "download.directory_upgrade" = TRUE,
      "safebrowsing.enabled" = TRUE,
      "download.default_directory" = download_path,
      ...
    )
  )
}

#' @rdname driver_options
#' @export
firefox_options <- function(cargs  = c('--width=1280','--height=800'), headless = TRUE,..., download_path = tempdir()){
  
  if(headless)
    cargs <- c("--headless",cargs)
  
  list(
    args  = cargs,
    prefs = list(
      'browser.download.folderList' = 2,
      'browser.download.lastDir' = download_path,
      'browser.download.dir' = download_path
    )
  )
}

#' @title Firefox and Chrome Drivers
#' @description Drivers for firefox and chrome to run the Shiny application
#' @param test_path path to run the tests, Default: tempdir()
#' @inheritParams RSelenium::rsDriver
#' @param opts Driver options from [firefox_driver] or [chrome_driver]
#' @return object of class [remoteDriver][RSelenium::remoteDriver]
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  firefox_rs <- firefox_driver()
#'  firefox_rs$client$navigate('https://www.google.com')
#'  firefox_rs$client$screenshot(display = TRUE)
#'  firefox_rs$client$close()
#'  firefox_rs$server$stop()
#'  }
#' }
#' @seealso 
#'  \code{\link[RSelenium]{rsDriver}}
#' @rdname driver
#' @export 
#' @importFrom RSelenium rsDriver
firefox_driver <- function(test_path = tempdir(),
                           verbose = FALSE, 
                           port = 4567L,
                           opts = firefox_options(download_path = test_path),...){
  
  RSelenium::rsDriver(
    browser = "firefox",
    verbose = verbose,
    port = port,
    extraCapabilities = list(
      "moz:firefoxOptions" = opts
    ),
    ...
  )
  
}

#' @rdname driver
#' @export 
#' @importFrom RSelenium rsDriver
chrome_driver <- function(test_path = tempdir(),
                          verbose = FALSE, 
                          port = 4567L,
                          opts = chrome_options(download_path = test_path),...){
  
  RSelenium::rsDriver(
    browser = "chrome",
    verbose = verbose,
    port = port,
    extraCapabilities = list(
      chromeOptions = opts
    ),
    ...
  )
  
}

