#' @keywords AIRSIS
#' @export
#' @title Apply Quality Control to Raw AIRSIS E-Sampler Dataframe
#' @param df single site dataframe created by airsis_downloadData()
#' @param valid_Longitude range of valid Longitude values
#' @param valid_Latitude range of valid Latitude values
#' @param remove_Lon_zero flag to remove rows where Longitude == 0
#' @param remove_Lat_zero flag to remove rows where Latitude == 0
#' @param valid_Flow range of valid Flow.l.m values
#' @param valid_AT range of valid AT.C. values
#' @param valid_RHi range of valid RHi... values
#' @param valid_Conc range of valid Conc.mg.m3. values
#' @description Perform various QC measures on AIRSIS E-Sampler data.
#' 
#' The following columns of data are tested against valid ranges:
#' \itemize{
#' \item{\code{Flow}}
#' \item{\code{AT}}
#' \item{\code{RHi}}
#' \item{\code{ConcHr}}
#' }
#' 
#' A \code{POSIXct datetime} column (UTC) is also added based on \code{Date.Time.GMT}.
#' 
#' @return Cleaned up dataframe of AIRSIS monitor data.
#' @seealso \code{\link{airsis_qualityControl}}

airsis_ESAMQualityControl <- function(df,
                                      valid_Longitude=c(-180,180),
                                      valid_Latitude=c(-90,90),
                                      remove_Lon_zero = TRUE,
                                      remove_Lat_zero = TRUE,
                                      valid_Flow = c(1.999,2.001),     # anything other than 2 is bad
                                      valid_AT = c(-Inf,150),
                                      valid_RHi = c(-Inf,55),
                                      valid_Conc = c(-Inf,984)) {
  
  # TODO:  What about Alarm?, 
  
  #   > names(df)
  #    [1] "MasterTable_ID"        "Alias"                 "Latitude"              "Longitude"            
  #    [5] "Conc.mg.m3."           "Flow.l.m."             "AT.C."                 "BP.PA."               
  #    [9] "RHx..."                "RHi..."                "WS.M.S."               "WD.Deg."              
  #   [13] "BV.V."                 "Alarm"                 "Start.Date.Time..GMT." "Serial.Number"        
  #   [17] "System.Volts"          "Data.1"                "Data.2"                "TimeStamp"            
  #   [21] "PDate"                 "monitorName"           "monitorType"          
  
  monitorName <- df$monitorName[1]
  
  # ----- Missing Values ------------------------------------------------------
  
  # Handle various missing value flags
  
  
  # ----- Location ------------------------------------------------------------
  
  # Latitude and longitude must be in range
  if (remove_Lon_zero) {
    goodLonMask <- !is.na(df$Longitude) & df$Longitude >= valid_Longitude[1] & df$Longitude <= valid_Longitude[2] & df$Longitude != 0
  } else {
    goodLonMask <- !is.na(df$Longitude) & df$Longitude >= valid_Longitude[1] & df$Longitude <= valid_Longitude[2]
  }
  
  if (remove_Lat_zero) {
    goodLatMask <- !is.na(df$Latitude) & df$Latitude >= valid_Latitude[1] & df$Latitude <= valid_Latitude[2] & df$Latitude != 0
  } else {    
    goodLatMask <- !is.na(df$Latitude) & df$Latitude >= valid_Latitude[1] & df$Latitude <= valid_Latitude[2]
  }
  
  badRows <- !(goodLonMask & goodLatMask)
  badRowCount <- sum(badRows)
  if (badRowCount > 0) {
    logger.info('Discarding %s rows with invalid location information', badRowCount)
    logger.debug('Bad location Longitudes:  %s', paste0(sort(df$Longitude[badRows]), collapse=", "))
    logger.debug('Bad location Latitudes:  %s', paste0(sort(df$Latitude[badRows]), collapse=", "))
  }
  
  df <- df[goodLonMask & goodLatMask,]
  
  
  # ----- Time ----------------------------------------------------------------
  
  # TODO:  How best to assign TimeStamp column with second accuracy to an hourly datetime variable?
  # TODO:  Should we use TimeStampm or PDate?
  # TODO:  Are these data in GMT?
  
  # Add a POSIXct datetime
  df$datetime <- lubridate::round_date(lubridate::mdy_hms(df$TimeStamp), unit="hour")
  
  
  # Leland Tarnay QC -----------------------------------------------------------
  
  ###tmp.2013_NIFC_GOES65_wrcc$concQA <- with(tmp.2013_NIFC_GOES65_wrcc,
  ###                                         ifelse(Flow < 2 "FlowLow",
  ###                                         ifelse(Flow > 2, "FlowHigh",
  ###                                         ifelse(AT > 150, "HighTemp",
  ###                                         ifelse(RHi > 55,"HighRHi",
  ###                                         ifelse(ConcHr < 0, "Negative",
  ###                                         ifelse(ConcHr > 984, "HighConc", 'OK')))))))
  ####create a concHR numerical column, with NA values that aren't verbose about errors..
  ###  
  ###tmp.2013_NIFC_GOES65_wrcc$concHR <- with(tmp.2013_NIFC_GOES65_wrcc,
  ###                                         ifelse(concQA == 'Negative', 0,
  ###                                         ifelse(concQA == 'OK', ConcHr, NA)))
  
  goodFlow <- !is.na(df$Flow.l.m.) & df$Flow.l.m. >= valid_Flow[1] & df$Flow.l.m. <= valid_Flow[2]
  goodAT <- !is.na(df$AT.C.) & df$AT.C. >= valid_AT[1] & df$AT.C. <= valid_AT[2]
  goodRHi <- !is.na(df$RHi...) & df$RHi... >= valid_RHi[1] & df$RHi... <= valid_RHi[2]
  goodConcHr <- !is.na(df$Conc.mg.m3.) & df$Conc.mg.m3. >= valid_Conc[1] & df$Conc.mg.m3. <= valid_Conc[2]
  gooddatetime <- !is.na(df$datetime) & df$datetime < lubridate::now("UTC") # saw a future date once
  
  logger.debug('Flow has %s missing or out of range values', sum(!goodFlow))
  if (sum(!goodFlow) > 0) logger.debug('Bad Flow values:  %s', paste0(sort(df$Flow.l.m.[!goodFlow]), collapse=", "))
  logger.debug('AT has %s missing or out of range values', sum(!goodAT))
  if (sum(!goodAT) > 0) logger.debug('Bad AT values:  %s', paste0(sort(df$AT.C.[!goodAT]), collapse=", "))
  logger.debug('RHi has %s missing or out of range values', sum(!goodRHi))
  if (sum(!goodRHi) > 0) logger.debug('Bad RHi values:  %s', paste0(sort(df$RHi...[!goodRHi]), collapse=", "))
  logger.debug('Conc has %s missing or out of range values', sum(!goodConcHr))
  if (sum(!goodConcHr) > 0) logger.debug('Bad Conc values:  %s', paste0(sort(df$Conc.mg.m3.[!goodConcHr]), collapse=", "))
  logger.debug('datetime has %s missing or out of range values', sum(!gooddatetime))
  if (sum(!gooddatetime) > 0) logger.debug('Bad datetime values:  %s', paste0(sort(df$datetime[!gooddatetime]), collapse=", "))
  
  goodMask <- goodFlow & goodAT & goodRHi & goodConcHr & gooddatetime
  
  df <- df[goodMask,]
  
  badQCCount <- sum(!goodMask)
  if (badQCCount > 0) {
    logger.info('Discarding %s rows because of QC logic', badQCCount)
  }
  
  
  # ----- More QC -------------------------------------------------------------
  
  # TODO:  Other QC?
  
  logger.debug('Retaining %d rows of validated measurements', nrow(df))
  
  
  return(df)
  
}