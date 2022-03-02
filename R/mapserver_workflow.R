library(sf) # r geospatial library
library(httr) # http request library

get_esri_rest <- function(mapServerUrl, layer="1", where="OBJECTID>0") {
  url <- httr::parse_url(url)
  url$path <- paste(url$path, layer, "query", sep = "/")
  url$query <- list(where = where, # filter results, default is to select all
                    outFields = "*", # select all fields
                    returnGeometry = "true",
                    f = "geojson") # return the results as a geojson
  request <- httr::build_url(url)
  
  # you can enter the request object into a browser to access the raw geojson returned from the query
  out_sf <- sf::st_read(request)
  return(out_sf)
}

# Example open data record: https://open.canada.ca/data/en/dataset/da99526e-284f-4e06-8d04-193785cd1a96
# The url below comes from the esri rest resources associated with the open data record.
# You want to make sure that it is a "MapServer" and not a "FeatureServer"
url <- "https://maps-cartes.ec.gc.ca/arcgis/rest/services/Active_Inactive_Disposal_at_Sea_Sites/MapServer"
data_sf <- get_esri_rest(url, layer="0")
# the layer number can be found in brackets after the layer name (0), or at the end of the URL
# you can also filter by fields:
data_sf <- get_esri_rest(url, layer="0", where="SiteCode = 'CA-AT-D004'")