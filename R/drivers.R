#' @title Firefox and Chrome Driver Options
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
#' @family driver
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
#' @family driver
#' @export
firefox_options <- function(cargs  = c('--width=1280','--height=800','--memory 1024mb'), headless = TRUE,..., download_path = tempdir()){
  
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
#' @family driver
#' @export 
#' @importFrom RSelenium rsDriver
#' @importFrom httpuv randomPort
firefox_driver <- function(test_path = tempdir(),
                           verbose = FALSE, 
                           port = httpuv::randomPort(),
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
#' @family driver
#' @export 
#' @importFrom RSelenium rsDriver
#' @importFrom httpuv randomPort
chrome_driver <- function(test_path = tempdir(),
                          verbose = FALSE, 
                          port = httpuv::randomPort(),
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


#' @title Attach Chrome Driver to Reactor
#' @description Attach chrome driver to a reactor object.
#' @param obj reactor object
#' @param test_path character, Path the child process will have access to on the master, Default: tempdir()
#' @param verbose logical, reactor willn notify the action taken. Default: TRUE
#' @param verbose_driver logical, start the webdriver verbosely. Default: FALSE
#' @param port integer, port to run the webdriver on, Default: httpuv::randomPort()
#' @param opts named list, options to initialize webdriver with. Default: chrome_options(download_path = test_path)
#' @param ... additional arguments to pass to \code{\link[RSelenium]{rsDriver}}
#' @return reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname set_chrome_driver
#' @family driver
#' @export 
#' @importFrom httpuv randomPort
set_chrome_driver <- function(
  obj,
  test_path = tempdir(),
  verbose = TRUE,
  verbose_driver = FALSE, 
  port = httpuv::randomPort(),
  opts = chrome_options(download_path = test_path),
  ...){
  
  if(verbose){
    reactor_message(names(obj$driver),to = 'chrome')
  }
  
  chrome = list(
    test_path = test_path,
    verbose = verbose_driver, 
    port = port,
    opts = opts
  )
  
  chrome <- append(chrome,list(...))
  
  obj$driver <- list(chrome = chrome)
  
  invisible(obj)
}

#' @title Attach Firefox Driver to Reactor
#' @description Attach firefox driver to a reactor object.
#' @param obj reactor object
#' @param test_path character, Path the child process will have access to on the master, Default: tempdir()
#' @param verbose logical, start the webdriver verbosely. Default: FALSE
#' @param port integer, port to run the webdriver on, Default: httpuv::randomPort()
#' @param opts named list, options to initialize firefox with. Default: chrome_options(download_path = test_path)
#' @param ... additional arguments to pass to \code{\link[RSelenium]{rsDriver}}
#' @return reactor object
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname set_firefox_driver
#' @family driver
#' @export 
#' @importFrom httpuv randomPort
set_firefox_driver <- function(
  obj,
  test_path = tempdir(),
  verbose = TRUE,
  verbose_driver = FALSE, 
  port = httpuv::randomPort(),
  opts = firefox_options(download_path = test_path),
  ...){
  
  if(verbose){
    reactor_message(names(obj$driver),to = 'firefox')
  }
  
  firefox = list(
    test_path = test_path,
    verbose = verbose_driver, 
    port = port,
    opts = opts
  )
  
  firefox <- append(firefox,list(...))
  
  obj$driver <- list(firefox = firefox)
  
  invisible(obj)
}

#' @title Driver Version
#' @description Retrieves chrome driver version installed.
#' @return character
#' @examples 
#' chrome_version()
#' gecko_version()
#' @seealso 
#'  \code{\link[pagedown]{find_chrome}}
#' @rdname driver_version
#' @family driver
#' @export 
#' @importFrom pagedown find_chrome
chrome_version <- function(){
  gsub('[^0-9.]','',system2(pagedown::find_chrome(),args = '--version',stdout = TRUE))
}

#' @rdname driver_version
#' @family driver
#' @export 
gecko_version <- function(){
  gsub('[^0-9.]','',system2('geckodriver',args = '-V',stdout = TRUE)[1])
}
