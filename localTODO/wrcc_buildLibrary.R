# #' @keywords WRCC
# #' @export
# #' @title Build a Local RData Library from Local WRCC Data
# #' @param dataDir directory where raw data files are located
# #' @param outputDir directory where data files and transcript will be written
# #' @param logLevel log level for output \code{['TRACE','DEBUG','INFO','WARNING','ERROR','FATAL']}
# #' @param transcript filename for logging output
# #' @description Smoke monitoring data from wrcc.com is downloaded, quality controlled
# #' and converted in to a collection of .RData files, each containing a \code{ws_monitor}
# #' for a particular UnitID.
# #' 
# #' By default, a transcript file will be generated containing information on the progress
# #' of data downlaod, quality control and restructuring. More detailed information is
# #' generated by setting \code{logLevel='DEBUG'}.
# #' 
# #' Setting \code{transcript=NULL} causes output to be sent to the console.
# #' @return Vector of file names created.
# #' @seealso \link{monitor_combineLibraryFiles}
# #' @references \href{http://usfs.wrcc.com}{Interagency Real Time Smoke Monitoring}
# #' @examples
# #' \dontrun{
# #' files <- wrcc_buildLibrary(dataDir='~/Data/WRCC', outputDir='~/Data/WRCC')
# #' monitor_combineLibraryFiles('~/Data/WRCC', files, 'WRCC.RData')
# #' wrcc <- <- wrcc_load(url='~/Data/WRCC/WRCC.RData')
# #' monitor_leaflet(wrcc)
# #' }
# 
# wrcc_buildLibrary <- function(dataDir='~/Data/WRCC', outputDir='~/Data/WRCC',
#                               logLevel='INFO', transcript='WRCC_TRANSCRIPT.txt') {
#   
#   # TODO:  Make sure transcript=NULL sends output to the console
#   
#   # Set up a new transcript file
#   if (is.null(transcript)) {
#     futile.logger::flog.appender(futile.logger::appender.console())
#   } else {
#     transcriptPath <- file.path(outputDir,transcript)
#     if ( file.exists(transcriptPath) ) {
#       file.remove(transcriptPath)
#     }
#     futile.logger::flog.appender(futile.logger::appender.file(transcriptPath))
#   }
#   
#   # Set log level
#   futile.logger::flog.threshold(get('logLevel'))
#   
#   # Silence other warning messages
#   options(warn=-1) # -1=ignore, 0=save/print, 1=print, 2=error
#   
#   # NOTE:  Data files were obtained, through Leland Tarnay, from the DRI programmer.
#   # NOTE:
#   # NOTE:  They can be generated by hand with the following series of actions per monitor:
#   # NOTE:
#   # NOTE:   * go to http://www.wrcc.dri.edu/cgi-bin/smoke.pl
#   # NOTE:   * click on an individual monitor
#   # NOTE:   * click on thet Data Details link on the left
#   # NOTE:   * adjust time selectors
#   # NOTE:   * select Data Format: HTML
#   # NOTE:   * click on Submit Info
#   
#   # List where saved filenames are stored
#   filenames <- list()
#   
#   # Find all of the *.out source data files (html formatted)
#   inputFilenames <- list.files(dataDir, '.*\\.out')
#   
#   for (file in inputFilenames) {
#     
#     futile.logger::flog.info('Working on file %s ---------------------------------------------------------', file)
#     
#     result <- try( df <- wrcc_readData(file.path(dataDir, file)),
#                    silent=TRUE )
#     
#     if ( class(result)[1] == "try-error" ) {
#       
#       err_msg <- geterrmessage()
#       if (stringr::str_detect(err_msg,'parsing is not supported')) {
#         futile.logger::flog.warn('Skipping %s: %s', file, err_msg)
#         next
#       } else if (stringr::str_detect(err_msg,'No data')) {
#         futile.logger::flog.debug('Skipping %s: no data found', file)
#         next
#       } else {
#         futile.logger::flog.warn('Skipping %s: %s', file, err_msg)
#         next
#       }
#       
#     } else {
#       
#       futile.logger::flog.debug('%s had %s rows of data', file, nrow(df))
#       
#     }
#     
#     # Sanity check -- do we have any data?
#     futile.logger::flog.info('File %s has %s rows of raw data', file, nrow(df))
#     if ( nrow(df) == 0 ) next
#     
#     # Now create a ws_monitor object from this
#     result <- try( ws_monitor <- wrcc_createMonitorObject(df, clusterDiameter=1000),
#                    silent=TRUE )
#     
#     if ( class(result)[1] == "try-error" ) {
#       err_msg <- geterrmessage()
#       futile.logger::flog.warn('Skipping file %s: %s', file, err_msg)
#       next
#     } else {
#       instrumentID <- stringr::str_sub(ws_monitor$meta$monitorID[1],1,-6) # strip off trailing "__###" (deployment id)
#       filename <- paste0(instrumentID,'.RData')
#       filenames[[file]] <- filename
#       filepath <- file.path(outputDir, filename)
#       save(ws_monitor, file=filepath)
#       futile.logger::flog.info('Saving data as %s', filepath)
#     }
#     
#   } # End of file loop
#   
#   # Return vector of filenames generated
#   return(unlist(filenames))
#   
# }
# 
