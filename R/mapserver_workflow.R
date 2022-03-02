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