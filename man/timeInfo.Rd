% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/timeInfo.R
\name{timeInfo}
\alias{timeInfo}
\title{Get Time Relatied Information}
\usage{
timeInfo(time, lon = NULL, lat = NULL, timezone = NULL)
}
\arguments{
\item{time}{POSIXct vector with specified timezone}

\item{lon}{longitude of the location of interest}

\item{lat}{latitude of the location of interest}

\item{timezone}{Olson timezone at the location of interest}
}
\value{
A dataframe with times and masks.
}
\description{
Calculate the local time at the target location, sunrise, sunset and solar 
noon times, and create several temporal masks.

If the \code{timezone} is provided it will be used. Otherwise, the \pkg{MazamaSpatialUtils}
package will be used to determine the timezone from \code{lon} and \code{lat}.

The returned dataframe will have as many rows as the length of the incoming UTC \code{time} vector
and will contain the following columns:
\itemize{
\item{\code{localTime} -- local clock time}
\item{\code{sunrise} -- time of sunrise on each localTime day}
\item{\code{sunset} -- time of sunset on each localTime day}
\item{\code{solarnoon} -- time of solar noon on each localTime day}
\item{\code{day} -- logical mask = TRUE between sunrise and sunset}
\item{\code{morning} -- logical mask = TRUE between sunrise and solarnoon}
\item{\code{afternoon} -- logical mask = TRUE between solarnoon and sunset}
\item{\code{night} -- logical mask = opposite of day}
}
}
\examples{
ti <- timeInfo(CarmelValley$data$datetime,
               CarmelValley$meta$longitude,
               CarmelValley$meta$latitude,
               CarmelValley$meta$timezone)
head(ti)
}

