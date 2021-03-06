# Updates to the PWFSLSmoke R Package

```
Utilities for working with PM2.5 monitoring data available
from the US EPA, AirNow, AIRSIS, WRCC and others.
```

----

## Version 0.8 -- Plotting Functions

### PWFSLSmoke 0.8.6

 * improved airsis_downloadHourlyData() now uses readr::read_delim() 

### PWFSLSmoke 0.8.5

### PWFSLSmoke 0.8.4

 * `monitor_combine()` now accepts a list of monitors instead of just two.
 * New `df_timeOfDaySpaghettiPlot()` for working with "df_" data (raw "engineering" data but cleaned up and augmented).
 * New `df_getHighlightDates()` function to find dates with unusual values in the "engineering" data.

### PWFSLSmoke 0.8.3

 * All new AIRSIS data processing

### PWFSLSmoke 0.8.1

 * Cleanup and regularization of plotting functions.

### PWFSLSmoke 0.8.0

 * Plotting functions added.

## Version 0.7 -- Initial Internal Release

### PWFSLSmoke 0.7.2

 * Removed AQI breaks for 1-3 hr and 8hr. Now only using 24-hr, daily avg. breaks. The package now only supports 24-hour AQI breaks.
 * Modified function signatures for `monitor_timeseriesPlot()`, `monitor_map()` and `monitor_leaflet()` to remove/modify their use of the `AQIStyle` argument.
 * Updated localExamples/Washington_August_2015.R

### PWFSLSmoke 0.7.1

 * Added data model vignette.
 * Documentation improvements.
 * New example in [localExamples](https://github.com/MazamaScience/PWFSLSmoke/tree/master/localExamples) directory.
 
### PWFSLSmoke 0.7.0

 * Initial extraction/refactoring of base code from [wildfireSmoke](https://github.com/MazamaScience/wildfireSmoke) package.
