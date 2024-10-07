# Load necessary libraries
library(sf)
library(httr)
library(R.utils)
library(s2)
library(osmdata)
library(dplyr)
library(dplyr)
library(magrittr) 

#' @importFrom magrittr %>%
NULL


# Source the provider-specific files
source("R/osm.R")
source("R/bing.R")
source("R/google.R")



# Main download_buildings function
#' Download Building Data from a Specified Provider
#'
#' This function downloads building data from either Google Open Buildings, OpenStreetMap (OSM),
#' or Bing Open Buildings using a bounding box (bbox) and saves it to the specified directory or file.
#'
#' @param bbox A numeric vector representing the bounding box coordinates in the format \code{c(min_lon, min_lat, max_lon, max_lat)}.
#' @param provider The data provider to use. Options are \code{"google"}, \code{"osm"}, or \code{"bing"} (default is \code{"google"}).
#' @param output_dir The directory where data will be saved for Google or Bing data (default is \code{"data/"}).
#' @param output_file The file path where OSM or Bing data should be saved (default is \code{"osm_buildings.geojson"} or \code{"bing_buildings.geojson"}).
#' @param delete_compressed Logical. Whether to delete the compressed file after uncompressing for Google data (default is \code{TRUE}).
#' @return A \code{sf} object containing all building geometries within the specified area.
#' @export
#' @examples
#' \dontrun{
#' # Download data from Google Open Buildings using a specified bounding box
#' bbox <- c(4.35, 50.85, 4.36, 50.86)
#' buildings_google <- download_buildings(bbox, provider = "google")
#'
#' # Download data from OpenStreetMap and save it to a specific file
#' buildings_osm <- download_buildings(bbox, provider = "osm", output_file = "osm_buildings.geojson")
#'
#' # Download data from Bing Open Buildings
#' buildings_bing <- download_buildings(bbox, provider = "bing", output_file = "bing_buildings.geojson")
#' }
download_buildings <- function(bbox, provider = "google", output_dir = "data/",
                               output_file = "osm_buildings.geojson", delete_compressed = TRUE) {
  # Validate bbox input
  if (length(bbox) != 4) {
    stop("The bbox parameter must be a numeric vector of length 4 in the format: c(min_lon, min_lat, max_lon, max_lat)")
  }
  
  if (provider == "google") {
    return(download_google_open_buildings(bbox, output_dir, delete_compressed))
  } else if (provider == "osm") {
    return(download_osm_buildings(bbox, output_file))
  } else if (provider == "bing") {
    return(download_bing_open_buildings(bbox, output_file))
  } else {
    stop("Invalid provider specified. Please use 'google', 'osm', or 'bing'.")
  }
}
