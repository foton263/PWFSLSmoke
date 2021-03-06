#' @keywords AIRSIS
#' @export
#' @title Obain AIRSIS Data and Create a Raw Dataframe
#' @param startdate desired start date (integer or character representing YYYYMMDD[HH])
#' @param enddate desired end date (integer or character representing YYYYMMDD[HH])
#' @param provider identifier used to modify baseURL \code{['APCD'|'USFS']}
#' @param unitID character or numeric AIRSIS unit identifier
#' @param clusterDiameter diameter in meters used to determine the number of clusters (see \code{addClustering})
#' @param baseUrl base URL for data queries
#' @param saveFile optional filename where raw CSV will be written
#' @return Raw dataframe of WRCC data.
#' @description Obtains monitor data from an AIRSIS webservice and converts
#' it into a quality controlled, metadata enhanced "raw" dataframe
#' ready for use with all \code{raw_~} functions.
#' 
#' Steps involved include:
#' 
#' \enumerate{
#'  \item{download CSV text}
#'  \item{parse CSV text}
#'  \item{apply quality control}
#'  \item{apply clustering to determine unique deployments}
#'  \item{enhance metadata to include: elevation, timezone, state, country, site name}
#' }
#' 
#' @note The downloaded CSV may be saved to a local file by providing an argument to the \code{saveFile} parameter.
#' @seealso \code{\link{airsis_downloadData}}
#' @seealso \code{\link{airsis_parseData}}
#' @seealso \code{\link{airsis_qualityControl}}
#' @seealso \code{\link{addClustering}}
#' 
#' @examples
#' \dontrun{
#' raw <- airsis_createRawDataframe(startdate=20160901, provider='USFS', unitID='1033')
#' raw <- raw_enhance(raw)
#' rawPlot_timeseries(raw,tlim=c(20160908,20160917))
#' }
#' 

airsis_createRawDataframe <- function(startdate=20020101,
                                      enddate=strftime(lubridate::now(),"%Y%m%d",tz="GMT"),
                                      provider=NULL, unitID=NULL,
                                      clusterDiameter=1000,
                                      baseUrl="http://xxxx.airsis.com/vision/common/CSVExport.aspx?",
                                      saveFile=NULL) {
  
  # Sanity checks
  if ( is.null(provider) ) {
    logger.error("Required parameter 'provider' is missing")
    stop(paste0("Required parameter 'provider' is missing"))
  }
  
  if ( is.null(unitID) ) {
    logger.error("Required parameter 'unitID' is missing")
    stop(paste0("Required parameter 'unitID' is missing"))
  }
  
  # Read in AIRSIS .csv data
  logger.info("Downloading AIRSIS data ...")
  fileString <- airsis_downloadData(startdate, enddate, provider, unitID, baseUrl)
  
  # Optionally save as a raw .csv file
  if ( !is.null(saveFile) ) {
    result <- try( cat(fileString, file=saveFile),
                   silent=TRUE )
    if ( "try-error" %in% class(result) ) {
      err_msg <- geterrmessage()
      logger.warn("Unable to save data to local file %s: %s", saveFile, err_msg)
    }
    # NOTE:  Processing continues even if we fail to write the local file
  }
  
  # Read csv raw data into a dataframe
  logger.info("Parsing data ...")
  df <- airsis_parseData(fileString)
  
  # Apply monitor-appropriate QC to the dataframe
  logger.info("Applying QC logic ...")
  df <- airsis_qualityControl(df)
  
  # Add clustering information to identify unique deployments
  logger.info("Clustering ...")
  df <- addClustering(df, lonVar='Longitude', latVar='Latitude', clusterDiameter=1000)
  
  return(df)
  
}
