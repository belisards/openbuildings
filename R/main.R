# Load necessary libraries
library(sf)
library(httr)
library(R.utils)
library(s2)
library(osmdata)
library(dplyr)
library(tidyverse)

# Source the provider-specific files
source("google.R")
source("osm.R")


# Main download_buildings function
#' Download Building Data from a Specified Provider
#'
#' This function downloads building data from either Google Open Buildings or OpenStreetMap (OSM)
#' using a bounding box (bbox) and saves it to the specified directory or file.
#'
#' @param bbox A numeric vector representing the bounding box coordinates in the format \code{c(min_lon, min_lat, max_lon, max_lat)}.
#' @param provider The data provider to use. Options are \code{"google"} or \code{"osm"} (default is \code{"google"}).
#' @param output_dir The directory where data will be saved for Google data (default is \code{"gob_raw_data/"}).
#' @param output_file The file path where OSM data should be saved (default is \code{"osm_buildings.geojson"}).
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
#' }
download_buildings <- function(bbox, provider = "google", output_dir = "gob_raw_data/",
                               output_file = "osm_buildings.geojson", delete_compressed = TRUE) {
  # Validate bbox input
  if (length(bbox) != 4) {
    stop("The bbox parameter must be a numeric vector of length 4 in the format: c(min_lon, min_lat, max_lon, max_lat)")
  }

  if (provider == "google") {
    return(download_google_open_buildings(bbox, output_dir, delete_compressed))
  } else if (provider == "osm") {
    return(download_osm_buildings(bbox, output_file))
  } else {
    stop("Invalid provider specified. Please use 'google' or 'osm'.")
  }
}


# # Load necessary libraries
# library(sf)
# library(httr)
# library(R.utils)
# library(s2)
# library(osmdata)
# library(dplyr)
# library(tidyverse)
#
# download_buildings <- function(bbox, provider = "google", output_dir = "gob_raw_data/",delete_compressed = TRUE) {
#   # Validate bbox input
#   if (length(bbox) != 4) {
#     stop("The bbox parameter must be a numeric vector of length 4 in the format: c(min_lon, min_lat, max_lon, max_lat)")
#   }
#
#   if (provider == "google") {
#     return(download_google_open_buildings(bbox, output_dir, delete_compressed))
#
#   } else if (provider == "osm") {
#     return(download_osm_buildings(bbox))
#
#   } else {
#     stop("Invalid provider specified. Please use 'google' or 'osm'.")
#   }
# }
#
# ##########
# download_google_open_buildings <- function(bbox, output_dir = "gob_raw_data/", delete_compressed = TRUE) {
#   if (!dir.exists(output_dir)) {
#     dir.create(output_dir, recursive = TRUE)
#   }
#
#   # Get the region code for the bbox center point (use average of bbox coordinates for the center)
#   centroid <- c(mean(c(bbox[1], bbox[3])), mean(c(bbox[2], bbox[4])))
#   region_code <- get_open_buildings_region_code(centroid)
#
#   download_and_uncompress_gob_data(region_code, output_dir, delete_compressed)
#   all_data <- load_all_buildings_data(output_dir)
#
#   return(all_data)
# }
#
#
# #######
# download_and_uncompress_gob_data <- function(region_code, output_dir, delete_compressed) {
#   url <- sprintf("https://storage.googleapis.com/open-buildings-data/v3/polygons_s2_level_4_gzip/%s_buildings.csv.gz", region_code)
#   compressed_file_path <- file.path(output_dir, sprintf("%s_buildings.csv.gz", region_code))
#   uncompressed_file_path <- file.path(output_dir, sprintf("%s_buildings.csv", region_code))
#
#   # Download the file
#   download.file(url, compressed_file_path, mode = "wb")
#   print("File downloaded.")
#
#   # Uncompress the file
#   R.utils::gunzip(compressed_file_path, destname = uncompressed_file_path, overwrite = TRUE)
#
#   if (delete_compressed && file.exists(compressed_file_path)) {
#     unlink(compressed_file_path)
#   }
# }
#
#
# load_all_buildings_data <- function(data_folder) {
#   file_list <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)
#
#   if (length(file_list) == 0) {
#     stop("No CSV files found in the specified folder.")
#   }
#
#   all_data <- do.call(rbind, lapply(file_list, read_sf))
#   return(all_data)
# }
#
# # OpenStreetMap Functions --------------------------------------------------------
#
# download_osm_buildings <- function(bbox, output_file = "osm_buildings.geojson") {
#   # Validate bbox input - this check ensures bbox is correctly formatted
#   if (length(bbox) != 4) {
#     stop("The bbox parameter must be a numeric vector of length 4 in the format: c(min_lon, min_lat, max_lon, max_lat)")
#   }
#
#   # Create an Overpass API query for buildings within the bounding box
#   osm_query <- opq(bbox = bbox) %>%
#     add_osm_feature(key = "building")
#
#   osm_data <- osmdata_sf(osm_query)
#   building_data <- osm_data$osm_polygons
#
#   if (nrow(building_data) == 0) {
#     warning("No building data found for the specified bbox area.")
#     return(NULL)
#   }
#
#   st_write(building_data, output_file, delete_dsn = TRUE)
#   message(sprintf("Building data successfully saved to '%s'", output_file))
#
#   return(building_data)
# }
#
# bbox <- c(14.90546335395436, 4.275308778796507, 14.919215493755678, 4.283059290376294)
#
# download_buildings(bbox,provider ="osm")
