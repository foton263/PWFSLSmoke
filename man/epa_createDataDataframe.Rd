% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/epa_createDataDataframe.R
\name{epa_createDataDataframe}
\alias{epa_createDataDataframe}
\title{Create EPA Data Dataframe}
\usage{
epa_createDataDataframe(df)
}
\arguments{
\item{df}{an EPA raw dataframe after metadata enhancement}
}
\value{
A \code{data} dataframe for use in a \emph{ws_monitor} object.
}
\description{
After addtional columns(i.e. \code{datetime}, and \code{monitorID}) 
have been applied to an EPA dataframe, we are ready to
extract the PM2.5 values and store them in a \code{data} dataframe
organized as time-by-monitor.

The first column of the returned dataframe is named \code{datetime} and
contains a \code{POSIXct} time in UTC. Additional columns contain data
for each separate monitorID.
}
\keyword{EPA}

