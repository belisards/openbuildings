#' Convert Bounding Box to Quadkey
#'
#' This function converts a bounding box (bbox) to a quadkey at a specified zoom level.
#'
#' @param bbox A numeric vector containing xmin, ymin, xmax, ymax.
#' @param zoom An integer representing the zoom level.
#' @return A character string representing the quadkey.
#' @export
bboxToQuadkey <- function(bbox, zoom) {
  tile_grid <- slippymath::bbox_to_tile_grid(bbox, zoom = zoom)
  tile_x <- tile_grid$tiles$x[1]
  tile_y <- tile_grid$tiles$y[1]
  
  quadkey <- quadkeyr::tileXY_to_quadkey(tile_x, tile_y, zoom)
  return(quadkey)
}

#' Download Files by Quadkey
#'
#' Downloads files matching the given quadkey from the provided dataframe.
#'
#' @param quadkey A character string representing the quadkey.
#' @param list_quadkeys A dataframe containing columns `QuadKey` and `Url`.
#' @return A character vector of downloaded file paths.
#' @export
downloadUrlsByQuadkey <- function(quadkey, list_quadkeys) {
  url_values <- list_quadkeys %>% dplyr::filter(QuadKey == quadkey) %>% dplyr::pull(Url)
  
  if (length(url_values) == 0) {
    stop("No matching QuadKey found.")
  }
  
  downloaded_files <- purrr::map_chr(url_values, ~{
    file_name <- paste0("data/", basename(.x))
    httr::GET(.x, httr::write_disk(file_name, overwrite = TRUE))
    message(paste("Downloaded:", file_name))
    file_name
  })
  
  return(downloaded_files)
}

#' Extract and Convert to GeoJSON
#'
#' Extracts .gz files, and if they contain CSV files, converts them to GeoJSON.
#'
#' @param downloaded_files A character vector of file paths.
#' @export
extractAndConvertToGeojson <- function(downloaded_files) {
  extracted_dir <- "data/extracted/"
  geojson_dir <- "data/geojson/"
  
  createDirIfNotExist(extracted_dir)
  createDirIfNotExist(geojson_dir)
  
  purrr::walk(downloaded_files, function(file) {
    if (grepl("\\.gz$", file)) {
      output_file <- paste0(extracted_dir, tools::file_path_sans_ext(basename(file)))
      decompressGzFile(file, output_file)
      
      # if (grepl("\\.csv$", output_file)) {
      #   geojson_file <- paste0(geojson_dir, tools::file_path_sans_ext(basename(output_file)), ".geojson")
      #   csvToGeojson(output_file, geojson_file)
      # }
    } else {
      message(paste("Skipping non-gz file:", file))
    }
  })
}

# Helper Functions

#' Create Directory If Not Exist
#'
#' Creates a directory if it does not already exist.
#'
#' @param dir_path A character string representing the directory path.
createDirIfNotExist <- function(dir_path) {
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
}

#' Decompress GZ File
#'
#' Decompresses a .gz file.
#'
#' @param input_file A character string representing the .gz file path.
#' @param output_file A character string representing the output file path.
decompressGzFile <- function(input_file, output_file) {
  con <- gzfile(input_file, "rb")
  writeBin(readBin(con, raw(), n = 1e7), output_file)  # Increased buffer size
  close(con)
  message(paste("Extracted:", input_file, "to", output_file))
}

#' CSV to GeoJSON Conversion
#'
#' Converts a CSV file to GeoJSON.
#'
#' @param csv_file A character string representing the CSV file path.
#' @param geojson_file A character string representing the GeoJSON file path.
csvToGeojson <- function(csv_file, geojson_file) {
  csv_data <- read.csv(csv_file, stringsAsFactors = FALSE)
  sf_data <- sf::st_as_sf(csv_data, coords = c("longitude", "latitude"), crs = 4326)
  sf::st_write(sf_data, geojson_file, delete_dsn = TRUE)
  message(paste("Converted CSV to GeoJSON:", geojson_file))
}


# Load required packages
library(dplyr)
library(httr)
library(purrr)
library(sf)
library(quadkeyr)

# Example usage:

# Define a bounding box (bbox) for a specific area
bbox <- c(xmin = 14.90546335395436, ymin = 4.275308778796507, xmax = 14.919215493755678, ymax = 4.283059290376294)

# Define the zoom level
zoom <- 9

# Convert the bounding box to a quadkey
quadkey <- bboxToQuadkey(bbox, zoom)
print(paste("Generated Quadkey:", quadkey))

# Load the list of quadkeys from a CSV (make sure to have an internet connection)
list_quadkeys <- read.csv("https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", stringsAsFactors = FALSE)

# Download URLs by the generated quadkey
downloaded_files <- downloadUrlsByQuadkey(quadkey, list_quadkeys)

# Extract the downloaded files and convert to GeoJSON format
extractAndConvertToGeojson(downloaded_files)

###########################################################################################################
# library(sf)
# library(geojsonsf)
# library(dplyr)
# library(httr)
# library(jsonlite)
# library(slippymath)
# library(dplyr)
# library(quadkeyr)
# library(jsonlite)

# bbox_to_quadkey <- function(bbox, zoom) {
#   # Get the tile grid from bbox
#   tile_grid <- bbox_to_tile_grid(bbox, zoom = zoom)
#   
#   # Extract the tile coordinates (assuming the first row of tiles contains the desired x and y)
#   tile_x <- tile_grid$tiles$x[1]
#   tile_y <- tile_grid$tiles$y[1]
#   
#   # Convert tile coordinates to quadkey
#   quadkey <- tileXY_to_quadkey(tile_x, tile_y, zoom)
#   
#   return(quadkey)
# }
# 
# # Example usage:
# bbox <- c(xmin = 14.90546335395436, ymin = 4.275308778796507, xmax = 14.919215493755678, ymax = 4.283059290376294)
# zoom <- 9
# 
# quadkey <- bbox_to_quadkey(bbox, zoom)
# 
# list_quadkeys <- read.csv("https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", stringsAsFactors = FALSE)
# 
# download_urls_by_quadkey <- function(quadkey, list_quadkeys) {
#   # Filter the dataframe to get the Url where QuadKey matches
#   url_value <- list_quadkeys[list_quadkeys$QuadKey == quadkey, "Url"]
#   
#   # If no match is found, return a message
#   if (length(url_value) == 0) {
#     message("No matching QuadKey found.")
#     return(NULL)
#   }
#   
#   # List to store filenames of downloaded files
#   downloaded_files <- c()
#   
#   # Loop through the URLs and download each
#   for (url in url_value) {
#     # Create a file name from the URL
#     file_name <- paste0("data/", basename(url))
#     
#     # Download the file
#     download.file(url, file_name)
#     
#     # Append the downloaded filename to the list
#     downloaded_files <- c(downloaded_files, file_name)
#     
#     # Optionally print the file name being downloaded
#     message(paste("Downloaded:", file_name))
#   }
#   
#   # Return the list of downloaded filenames
#   return(downloaded_files)
# }
# 
# library(jsonlite)
# 
# # Function to extract .gz files and then convert CSV files to GeoJSON
# extract_and_convert_to_geojson <- function(downloaded_files) {
#   # Create directories for extracted files and GeoJSON files
#   extracted_dir <- "data/extracted/"
#   geojson_dir <- "data/geojson/"
#   
#   if (!dir.exists(extracted_dir)) {
#     dir.create(extracted_dir, recursive = TRUE)
#   }
#   
#   if (!dir.exists(geojson_dir)) {
#     dir.create(geojson_dir, recursive = TRUE)
#   }
#   
#   # Loop through the downloaded files and process .gz files
#   for (file in downloaded_files) {
#     if (grepl("\\.gz$", file)) {
#       # Uncompress the .gz file
#       output_file <- paste0(extracted_dir, tools::file_path_sans_ext(basename(file)))
#       
#       con <- gzfile(file, "rb")
#       writeBin(readBin(con, raw(), n = 1e6), output_file)
#       close(con)
#       
#       message(paste("Extracted:", file, "to", output_file))
#       
#       # If the extracted file is a CSV, convert it to GeoJSON
#       if (grepl("\\.csv$", output_file)) {
#         csv_file <- output_file
#         geojson_file <- paste0(geojson_dir, tools::file_path_sans_ext(basename(csv_file)), ".geojson")
#         
#         # Call the CSV to GeoJSON conversion function
#         csv_to_geojson(csv_file, geojson_file)
#       }
#       
#     } else {
#       message(paste("Skipping non-gz file:", file))
#     }
#   }
# }
# 
# downloaded_files <- download_urls_by_quadkey(quadkey, list_quadkeys)
# 
# extract_and_rename_geojson <- function(downloaded_files) {
#   # Create a directory to store the extracted GeoJSON files
#   geojson_dir <- "data/geojson/"
#   
#   if (!dir.exists(geojson_dir)) {
#     dir.create(geojson_dir, recursive = TRUE)
#   }
#   
#   # Initialize a vector to store the names of the extracted files
#   renamed_files <- c()
#   
#   # Loop through the downloaded .gz files
#   for (file in downloaded_files) {
#     if (grepl("\\.gz$", file)) {
#       # Generate output file path by removing the .gz extension and renaming to .geojson
#       geojson_file <- paste0(geojson_dir, tools::file_path_sans_ext(basename(file)), ".geojson")
#       
#       # Uncompress the .gz file and rename it
#       con <- gzfile(file, "rb")
#       writeBin(readBin(con, raw(), n = 1e6), geojson_file)
#       close(con)
#       
#       # Add the renamed file to the list of renamed files
#       renamed_files <- c(renamed_files, geojson_file)
#       
#       message(paste("Extracted and renamed:", file, "to", geojson_file))
#     } else {
#       message(paste("Skipping non-gz file:", file))
#     }
#   }
#   
#   # Return the list of renamed files
#   return(renamed_files)
# }
# 
# filenames <- extract_and_rename_geojson(downloaded_files)

# library(jsonlite)
# 
# merge_geojson_files <- function(filenames, output_geojson_file) {
#   # Initialize a list to store all features from the GeoJSON files
#   all_features <- list()
#   
#   # Loop through the filenames and read each GeoJSON file
#   for (file in filenames) {
#     # Read the GeoJSON file
#     geojson_data <- fromJSON(file)
#     
#     # Combine the features from the current file into the all_features list
#     all_features <- c(all_features, geojson_data$features)
#     
#     message(paste("Merged features from:", file))
#   }
#   
#   # Create the merged GeoJSON structure
#   merged_geojson <- list(
#     type = "FeatureCollection",
#     features = all_features
#   )
#   
#   # Write the merged GeoJSON to the output file
#   write_json(merged_geojson, output_geojson_file, pretty = TRUE)
#   
#   message(paste("Merged GeoJSON saved to:", output_geojson_file))
# }
# 
# merge_geojson_files(filenames, "data/merged_output.geojson")
