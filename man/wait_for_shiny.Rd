% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{wait_for_shiny}
\alias{wait_for_shiny}
\title{Wait for shiny}
\usage{
wait_for_shiny(obj, maxiter = 20, ...)
}
\arguments{
\item{obj}{reactor object}

\item{maxiter}{Number of iterations to wait for shiny, Default: 20}

\item{...}{pass arguments to time logger.}
}
\value{
reactor object
}
\description{
Holds the system while shiny is invalidating.
}
\details{
R side explicit timeout is defined as 0.02 * iteration number in seconds.
}
\examples{
\dontrun{
if(interactive()){
 #EXAMPLE1
 }
}
}
\seealso{
Other reactor: 
\code{\link{get_busy_time}()},
\code{\link{init_reactor}()},
\code{\link{kill_app}()},
\code{\link{navigate_to_app}()},
\code{\link{reactor_path}()},
\code{\link{read_reactor}()},
\code{\link{reset_counter}()},
\code{\link{start_reactor}()}
}
\concept{reactor}
