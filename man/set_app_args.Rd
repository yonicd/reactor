% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/app_args.R
\name{set_runapp_args}
\alias{set_runapp_args}
\alias{set_golem_args}
\title{Attach Commands for Shiny Application to Reactor}
\usage{
set_runapp_args(
  obj,
  appDir = getwd(),
  test_port = httpuv::randomPort(),
  test_path = tempdir(),
  test_ip = getOption("shiny.host", "127.0.0.1"),
  test_trace = FALSE,
  verbose = TRUE
)

set_golem_args(
  obj,
  package_name = "",
  test_port = httpuv::randomPort(),
  test_path = tempdir(),
  test_ip = getOption("shiny.host", "127.0.0.1"),
  test_trace = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{obj}{reactor object}

\item{appDir}{The application to run. Should be one of the following (Default: getwd()):
\itemize{
\item A directory containing server.R, plus, either ui.R or a www directory
that contains the file index.html.
\item A directory containing app.R.
\item An .R file containing a Shiny application, ending with an expression that produces a Shiny app object.
}}

\item{test_port}{integer, port to run the app on. Default: httpuv::randomPort()}

\item{test_path}{character, Path the child process will have access to on the master, Default: tempdir()}

\item{test_ip}{The IPv4 address that the application should listen on.}

\item{test_trace}{logical, turn on the shiny.trace option in the background proccess?. Default: FALSE}

\item{verbose}{logical, reactor willn notify the action taken. Default: TRUE}

\item{package_name}{name of the golem package}
}
\value{
reactor object
}
\description{
Attach commands for starting shiny application
using runApp or golem commands to the reactor object.
}
\examples{
\dontrun{
if(interactive()){
 #EXAMPLE1
 }
}
}
\seealso{
Other application: 
\code{\link{runApp_args}()}

Other application: 
\code{\link{runApp_args}()}
}
\concept{application}
