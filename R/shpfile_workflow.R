install.packages("ckanr") #you need to install the packages every time since it is a fresh container
library(ckanr)
ckanr_setup(url="https://open.canada.ca/data")
library(sf)
library(httr)
library(here)
# --------------download_extract_validate_sf-----------------
# Function that downloads and processes a file into an sf object
#
# Inputs:
# 1. zipUrl: URL string of zipped file containing the spatial data
# 2. gdbLayer: if the file is a geodatabase, name of the layer to be read, NULL if resource is a .shp file
#
# Outputs:
# 1 .out_sf: output sf object containing spatial data
download_extract_validate_sf <- function(zipUrl, gdbLayer = NULL) {
  # set paths:
  tempDir <- here::here("temp") # you'll need to set this for your case
  temp <- file.path(tempDir, "temp.zip")
  
  download.file(zipUrl, temp)
  utils::unzip(temp, exdir = tempDir)
  # if there's a shape file read that:
  shpFile <- list.files(tempDir, recursive=TRUE, pattern="\\.shp$", full.names = TRUE)
  gdbDir <- list.files(tempDir, recursive=TRUE, pattern="\\.gdb$",
                       include.dirs = TRUE, full.names = TRUE)
  if (length(shpFile) > 0) {
    out_sf <- st_read(shpFile, stringsAsFactors = FALSE)
  } else if (length(gdbDir) > 0) {
    out_sf <- st_read(gdbDir, stringsAsFactors = FALSE, layer = gdbLayer)
    out_sf$geometry <- st_geometry(out_sf)
  }
  
  out_sf <- st_make_valid(out_sf)
  out_sf <- st_transform(out_sf, crs = 4326)
  
  # cleanup
  tempFiles <- list.files(tempDir, include.dirs = T, full.names = T, recursive = T)
  unlink(tempFiles, recursive = TRUE)
  
  return(out_sf)
}

# example:
# the Resource id is the last part of the resource link: https://open.canada.ca/data/en/dataset/8fafd919-fcbe-43a3-a911-3d9461273441/resource/3af8ad03-c0da-4cfa-940d-d757c0c24cb7
# the resource id is NOT static, it changes when the resource is updated. The package id is constant though.
resId <- "3af8ad03-c0da-4cfa-940d-d757c0c24cb7"
res <- resource_show(resId)
data_sf <- download_extract_validate_sf(res$url)