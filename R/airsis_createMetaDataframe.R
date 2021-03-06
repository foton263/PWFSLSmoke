#' @keywords AIRSIS
#' @export
#' @title Create AIRSIS Site Location Metadata Dataframe
#' @param df single site AIRSIS dataframe after metadata enhancement
#' @return A \code{meta} dataframe for use in a emph{ws_monitor} object.
#' @description After an AIRSIS dataframe has been enhanced with 
#' additional columns generated by \code{addClustering} we are ready to 
#' pull out site information associated with unique deployments.
#' 
#' These will be rearranged into a dataframe organized as deployment-by-property
#' with one row for each monitor deployment.
#'
#' This site information found in \code{df} is augmented so that we end up with a uniform
#' set of properties associated with each monitor deployment. The list of
#' columns in the returned \code{meta} dataframe is:
#' 
#' \preformatted{
#' > names(meta)
#'  [1] "AQSID"          "siteCode"       "siteName"       "status"        
#'  [5] "agencyID"       "agencyName"     "EPARegion"      "latitude"      
#'  [9] "longitude"      "elevation"      "timezone"       "GMTOffsetHours"
#' [13] "countryCode"    "FIPSMSACode"    "MSAName"        "FIPSStateCode" 
#' [17] "stateCode"      "GNISCountyCode" "countyName"     "monitorID"
#' [21] "monitorType"     
#' }
#' 
#' @seealso \code{\link{addGoogleMetadata}}
#' @seealso \code{\link{addMazamaMetadata}}


airsis_createMetaDataframe <- function(df) {

  # Sanity check -- df must have a monitorType
  if ( !'monitorType' %in% names(df) ) {
    logger.error("No 'monitorType' column found in 'df' dataframe with columns: %s", paste0(names(df), collapse=", "))
    stop(paste0("No 'monitorType' column found in 'df' dataframe."))
  }
  
  monitorType <- unique(df$monitorType)
  
  # Sanity check -- df must have only one monitorType
  if ( length(monitorType) > 1 ) {
    logger.error("Multiple monitor types found in 'df' dataframe: %s", paste0(monitorType, collapse=", "))
    stop(paste0("Multiple monitor types found in 'df' dataframe."))
  }
  
  monitorType <- monitorType[1]
  
  # Sanity check -- deploymentID must exist
  if ( !'deploymentID' %in% names(df) ) {
    logger.error("No 'deploymentID' column found in 'df' dataframe with columns %s", paste0(names(df), collapse=", "))
    stop(paste0("No 'deploymentID' column found in 'df' dataframe.  Have you run addClustering()?"))
  }
  
  # Pull out unique deployments
  df <- df[!duplicated(df$deploymentID),]
  
  logger.debug("Dataframe contains %d unique deployment(s)", nrow(df))
  
  # Our dataframe now contains the following columns:
  #
  #   > names(df)
  #    [1] "MasterTable_ID" "Alias"          "Latitude"       "Longitude"      "Date.Time.GMT"  "COncRT"        
  #    [7] "ConcHr"         "Flow"           "W.S"            "W.D"            "AT"             "RHx"           
  #   [13] "RHi"            "BV"             "FT"             "Alarm"          "Type"           "Serial.Number" 
  #   [19] "Version"        "Sys..Volts"     "TimeStamp"      "PDate"          "monitorName"    "monitorType"      
  #   [25] "datetime"       "deploymentID"   "medoidLon"      "medoidLat"     
  #
  # On 2016-01-31, the following columns were found in:
  #   https://smoke.airfire.org/RData/AirNowTech/AirNowTech_PM2.5_SitesMetadata.RData
  #
  #   > meta <- get(load('~/Downloads/AirNowTech_PM2.5_SitesMetadata.RData'))
  #   > str(meta)
  #   'data.frame':	1106 obs. of  24 variables:
  #     $ AQSID         : chr  "000020301" "000030701" "000040801" "000040203" ...
  #   $ siteCode      : chr  "0301" "0701" "0801" "0203" ...
  #   $ siteName      : chr  "WELLINGTON" "AYLESFORD MOUNTAIN" "CANTERBURY" "FOREST HILLS" ...
  #   $ status        : Factor w/ 2 levels "Active","Inactive": 1 1 1 1 1 1 1 1 1 1 ...
  #   $ agencyID      : Factor w/ 125 levels "AB1","AK1","AL1",..: 27 27 27 27 27 27 27 27 30 30 ...
  #   $ agencyName    : Factor w/ 125 levels "Alabama Department of Environmental Management",..: 27 27 27 27 27 27 27 27 61 61 ...
  #   $ EPARegion     : Factor w/ 13 levels "CA","MX","R1",..: 1 1 1 1 1 1 1 1 1 1 ...
  #   $ latitude      : num  46.5 45 46 45.3 46 ...
  #   $ longitude     : num  -64 -65 -67.5 -66 -66.6 ...
  #   $ elevation     : num  33.9 230 0 57 0 ...
  #   $ GMTOffsetHours: num  -4 -4 -4 -4 -4 -4 -4 -4 -5 -5 ...
  #   $ countryCode   : Factor w/ 3 levels "CA","MX","US": 1 1 1 1 1 1 1 1 1 1 ...
  #   $ FIPSCMSACode  : Factor w/ 1 level "": 1 1 1 1 1 1 1 1 1 1 ...
  #   $ CMSAName      : Factor w/ 1 level "": 1 1 1 1 1 1 1 1 1 1 ...
  #   $ FIPSMSACode   : Factor w/ 467 levels "","10140","10180",..: 1 1 1 1 1 1 1 1 1 1 ...
  #   $ MSAName       : Factor w/ 467 levels "","Aberdeen, WA",..: 1 1 1 1 1 1 1 1 1 1 ...
  #   $ FIPSStateCode : Factor w/ 56 levels "00","01","02",..: 1 1 1 1 1 1 1 1 1 1 ...
  #   $ stateCode     : Factor w/ 55 levels "AK","AL","AR",..: 6 6 6 6 6 6 6 6 6 6 ...
  #   $ GNISCountyCode: Factor w/ 1027 levels "00001","00002",..: 2 3 4 4 4 4 4 4 5 5 ...
  #   $ countyName    : Factor w/ 789 levels "ABBEVILLE","ADA",..: 578 514 499 499 499 499 499 499 585 585 ...
  #   $ GNISCityCode  : Factor w/ 1 level "": 1 1 1 1 1 1 1 1 1 1 ...
  #   $ cityName      : Factor w/ 1 level "": 1 1 1 1 1 1 1 1 1 1 ...
  #   $ timezone      : chr  "America/Halifax" "America/Halifax" "America/Moncton" "America/Moncton" ...
  #   $ monitorID     : chr  "000020301" "000030701" "000040801" "000040203" ...
  #
  #     
  # We will create a reduced version for the AIRSIS data with at least:
  # 
  #  [1] "AQSID"          "siteCode"       "siteName"       "status"        
  #  [5] "agencyID"       "agencyName"     "EPARegion"      "latitude"      
  #  [9] "longitude"      "elevation"      "timezone"       "GMTOffsetHours" 
  # [13] "countryCode"    "FIPSMSACode"    "MSAName"        "FIPSStateCode"   
  # [17] "stateCode"      "GNISCountyCode" "countyName"     "monitorID"
  # [21] "monitorType"
  # 
  # Many of these fields will be empty
  
  # TODO:  Further reduce metadata columns to omit FIPS and GNIS codes, etc.
  
  # Create empty dataframe
  meta <- as.data.frame(matrix(nrow=nrow(df),ncol=21))
  
  colNames <- c('AQSID','siteCode','siteName','status',
                'agencyID','agencyName','EPARegion','latitude',
                'longitude','elevation','timezone','GMTOffsetHours',
                'countryCode','FIPSMSACode','MSAName','FIPSStateCode',
                'stateCode','GNISCountyCode','countyName','monitorID',
                'monitorType')
  
  names(meta) <- colNames
  
  # Assign data where we have it
  # NOTE:  We use monitorID as a unique identifier instead of AQSID so that we can be
  # NOTE:  consistent when working with non-AirNow datasets.
  meta$longitude <- df$medoidLon
  meta$latitude <- df$medoidLat
  meta$monitorID <- paste0(make.names(df$monitorName),'__',sprintf("%03d",df$deploymentID))
  meta$monitorType <- df$monitorType
  
  # Assign rownames
  rownames(meta) <- meta$monitorID
  
  # Add timezones, state and country codes
  meta <- addMazamaMetadata(meta)
  
  # TODO:  Could assign other spatial identifiers like EPARegion, etc.
  
  # agencyName
  if ( monitorType == "EBAM" ) {
    NPSMask <- stringr::str_detect(df$Alias,'^NPS ')
    USFSMask <- stringr::str_detect(df$Alias,'^USFS')
    meta$agencyName[NPSMask] <- 'National Park Service'
    meta$agencyName[USFSMask] <- 'United States Forest Service'
  }
  
  # Add elevation, siteName and countyName
  meta <- addGoogleMetadata(meta)

  # Convert some columns to character even if they have all NA
  characterColumns <- c('AQSID','siteCode','siteName','countyName','timezone','monitorID','monitorType')
  for (colName in characterColumns) {
    meta[[colName]] <- as.character(meta[[colName]])
  }

  logger.debug("Created 'meta' dataframe with %d rows and %d columns", nrow(meta), ncol(meta))
  
  return(meta)
  
}
