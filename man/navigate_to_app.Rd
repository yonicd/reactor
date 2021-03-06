% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{navigate_to_app}
\alias{navigate_to_app}
\title{Navigate to Application}
\usage{
navigate_to_app(obj, silent = FALSE)
}
\arguments{
\item{obj}{reactor object}

\item{silent}{logical, start silently. Default: FALSE}
}
\value{
obj reactor object
}
\description{
Navigating to application after reactor startup.
}
\examples{
\dontrun{
if(interactive()){
 #EXAMPLE1
 }
}
}
\seealso{
\code{\link[glue]{glue}}

Other reactor: 
\code{\link{get_busy_time}()},
\code{\link{init_reactor}()},
\code{\link{kill_app}()},
\code{\link{reactor_path}()},
\code{\link{read_reactor}()},
\code{\link{reset_counter}()},
\code{\link{start_reactor}()},
\code{\link{wait_for_shiny}()}
}
\concept{reactor}
