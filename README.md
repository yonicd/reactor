
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reactor <img src="https://github.com/yonicd/hex/raw/master/images/logos/reactor.png" align="right" class="logo"/>

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![R-CMD-check](https://github.com/yonicd/reactor/workflows/R-CMD-check/badge.svg)](https://github.com/yonicd/reactor/actions)
[![pkgdown](https://github.com/yonicd/reactor/workflows/pkgdown/badge.svg)](https://github.com/yonicd/reactor/actions)
[![Reactor](https://github.com/yonicd/reactor/workflows/Reactor/badge.svg)](https://github.com/yonicd/reactor/actions)
[![Covrpage
Summary](https://img.shields.io/badge/covrpage-Last_Build_2020_12_21-brightgreen.svg)](https://tinyurl.com/yd2odf5g)
<!-- badges: end -->

When developing Shiny apps there is a lot of reactivity problems that
can arise when one `reactive` or `observe` element triggers other
elements. In some cases these can create cascading reactivity (the
horror). The goal of `reactor` is to diagnose these reactivity problems
and then plan unit tests to avert them during development to make
development less painful.

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("yonicd/reactor")
```

## Usage

Reactor is a pipeline driven api where the user does not need to learn
RSelenium in order to be able to drive their applications

### Initializing Reactor

Start by creating a reactor class object

``` r
library(reactor)
obj <- init_reactor()
obj
#> reactor:
#>   processx: ~
#>   driver: ~
```

### Populating Specifications

You can see it is expecting to be populated by two objects

-   **processx**: Specifications for the background process that will
    host the application
-   **driver**: Specifications for the webdriver that will interact with
    the application in the background process

Reactor comes with functions to help you create these specifications

-   **processx**:
    -   `set_runapp_args()` : Assumes that the application is located in
        a path on the machine and uses `shiny::runApp` as the function
        to launch the application
    -   `set_golem_args()`: Assumes that the application is a
        [golem](https://github.com/ThinkR-open/golem) package and uses
        the `golem` logic to launch the application.
-   **driver**:
    -   `set_chrome_driver()`: Launches `RSelenium` with a chrome
        webdriver
    -   `set_firefox_driver()`: Launches `RSelenium` with a firefox
        (gecko) webdriver

``` r
obj <- obj%>%
  set_runapp_args(
    appDir = system.file('examples/good_app.R',package = 'reactor')
  )%>%
  set_chrome_driver()
```

<details closed>
<summary>
<span title="Click to Open"> reactor object </span>
</summary>

``` yml
reactor:
  processx:
    runApp:
      test_port: 31443
      test_path: /var/folders/kx/t4h_mm1910sb7vhm_gnfnx2c0000gn/T//RtmpVVpx6P
      test_ip: 127.0.0.1
      appDir: /Users/yonis/projects/reactor/inst/examples/good_app.R
  driver:
    chrome:
      test_path: /var/folders/kx/t4h_mm1910sb7vhm_gnfnx2c0000gn/T//RtmpVVpx6P
      verbose: no
      port: 34303
      opts:
        args:
        - --headless
        - --disable-gpu
        - --window-size=1280,800
        prefs:
          profile.default_content_settings.popups: 0
          download.prompt_for_download: no
          download.directory_upgrade: yes
          safebrowsing.enabled: yes
          download.default_directory: /var/folders/kx/t4h_mm1910sb7vhm_gnfnx2c0000gn/T//RtmpVVpx6P
```

</details>

<br>

If you want turn off headless mode you can update the object

``` r
obj <- obj%>%
  set_chrome_driver(
     opts = chrome_options(headless = FALSE)
  )
```

<details closed>
<summary>
<span title="Click to Open"> reactor object </span>
</summary>

``` yml
reactor:
  processx:
    runApp:
      test_port: 31443
      test_path: /var/folders/kx/t4h_mm1910sb7vhm_gnfnx2c0000gn/T//RtmpVVpx6P
      test_ip: 127.0.0.1
      appDir: /Users/yonis/projects/reactor/inst/examples/good_app.R
  driver:
    chrome:
      test_path: /var/folders/kx/t4h_mm1910sb7vhm_gnfnx2c0000gn/T//RtmpVVpx6P
      verbose: no
      port: 34303
      opts:
        args:
        - --headless
        - --disable-gpu
        - --window-size=1280,800
        prefs:
          profile.default_content_settings.popups: 0
          download.prompt_for_download: no
          download.directory_upgrade: yes
          safebrowsing.enabled: yes
          download.default_directory: /var/folders/kx/t4h_mm1910sb7vhm_gnfnx2c0000gn/T//RtmpVVpx6P
```

</details>

<br>

### Starting Reactor

Once we have specifications in place we can start reactor using
`start_reactor()`.

``` r
obj%>%
  start_reactor()
```

### Interacting with the application

Now that the app is running we can send to the webdriver to interact
with the application

-   `set_id_value()`:
    -   expects an input id and the new value
    -   returns back the reactor object

``` r
obj%>%
  set_id_value('n',500)
```

The user can use the following utility functions to interact and query
with an application

Inject:

-   Inputs
    -   `set_id_value()`: Sets a value for a shiny input object by id
-   JavaScript
    -   `execute()`: Executes a JavaScript call

Query:

-   Inputs
    -   `query_input_names()`: Returns names of the shiny input ids
    -   `query_input_id()`: Returns current values of a shiny input by
        id
-   Outputs
    -   `query_output_names()`: Returns names of the shiny output ids
    -   `query_output_id()`: Returns current values of a shiny output by
        id
-   JavaScript
    -   `query()`: Returns a value from JavaScript call

### Closing Reactor

To safely close reactor and all the child processes use `kill_app()`:

``` r
obj%>%
  kill_app()
```

### Pipeline Operations

Because each function is returning the reactor object it is simple to
create reactor pipelines.

Reactor will wait for shiny to finish each action before proceeding to
the next one.

``` r
init_reactor()%>%
  set_runapp_args(
    appDir = system.file('examples/good_app.R',package = 'reactor')
  )%>%
  set_chrome_driver()%>%
  start_reactor()%>%
  set_id_value('n',500)%>%
  set_id_value('n',300)%>%
  kill_app()
```

### Testing Expectations

Finally reactor tests reactivity expectations in a `testthat` framework
using the builtin `expect_reactivity()` function

``` r
init_reactor()%>%
  set_runapp_args(
    appDir = system.file('examples/good_app.R',package = 'reactor')
  )%>%
  set_chrome_driver()%>%
  start_reactor()%>%
  set_id_value('n',500)%>%
  expect_reactivity('hist',1)%>%
  set_id_value('n',200)%>%
  expect_reactivity('hist',2)%>%
  kill_app()
```
