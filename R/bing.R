#' Convert Bounding Box to Quadkey
#'
#' This function converts a bounding box (bbox) to a quadkey at a specified zoom level.
#'
#' @param bbox A numeric vector containing xmin, ymin, xmax, ymax.
#' @param zoom An integer representing the zoom level.
#' @return A character string representing the quadkey.
#' @examples
#' bbox <- c(xmin = 14.9, ymin = 4.2, xmax = 14.91, ymax = 4.28)
#' zoom <- 9
#' bbox_to_quadkey(bbox, zoom)
#' @export
bbox_to_quadkey <- function(bbox, zoom) {
  tile_grid <- slippymath::bbox_to_tile_grid(bbox, zoom = zoom)
  tile_x <- tile_grid$tiles$x[1]
  tile_y <- tile_grid$tiles$y[1]
  
  quadkey <- quadkeyr::tileXY_to_quadkey(tile_x, tile_y, zoom)
  return(quadkey)
}

#' Download URLs by Quadkey
#'
#' This function downloads URLs corresponding to a given quadkey.
#'
#' @param quadkey A character string representing the quadkey.
#' @param list_quadkeys A data frame containing QuadKey and Url columns.
#' @param output_dir A character string representing the output directory path.
#' @return A character vector of downloaded file paths.
#' @examples
#' # Assuming list_quadkeys is loaded
#' quadkey <- "023112"
#' download_urls_by_quadkey(quadkey, list_quadkeys)
#' @export
download_urls_by_quadkey <- function(quadkey, list_quadkeys, output_dir = "data/bing/") {
  create_dir_if_not_exist(output_dir)
  
  url_values <- dplyr::filter(list_quadkeys, QuadKey == quadkey) %>% dplyr::pull(Url)
  
  if (length(url_values) == 0) {
    stop("No matching QuadKey found.")
  }
  
  downloaded_files <- purrr::map_chr(url_values, ~{
    file_name <- file.path(output_dir, basename(.x))
    httr::GET(.x, httr::write_disk(file_name, overwrite = TRUE))
    message(paste("Downloaded:", file_name))
    file_name
  })
  
  return(downloaded_files)
}

#' Extract and Convert to GeoJSON
#'
#' Extracts .gz files and converts CSV files to GeoJSON format.
#'
#' @param downloaded_files A character vector of file paths.
#' @export
extract_and_rename_as_geojson <- function(downloaded_files) {
  purrr::walk(downloaded_files, function(file) {
    if (grepl("\.gz$", file)) {
      output_file <- tools::file_path_sans_ext(file)
      
      # Decompress the .gz file
      decompress_gz_file(file, output_file)
      
      # Remove the original .gz file
      file.remove(file)
      
      # If the output is a CSV, rename to GeoJSON extension
      if (grepl("\.csv$", output_file)) {
        geojson_file <- paste0(tools::file_path_sans_ext(output_file), ".geojson")
        file.rename(output_file, geojson_file)
        message(paste("Renamed CSV to GeoJSON extension:", geojson_file))
      }
      
    } else {
      message(paste("Skipping non-gz file:", file))
    }
  })
}

#' Merge GeoJSON Files
#'
#' This function merges multiple GeoJSON files into a single GeoJSON.
#'
#' @param geojson_files A character vector of GeoJSON file paths.
#' @param output_file A character string representing the output GeoJSON file path.
#' @export
merge_geojson_files <- function(geojson_files, output_file) {
  geojson_list <- purrr::map(geojson_files, ~jsonlite::fromJSON(.x))
  merged_features <- do.call(c, lapply(geojson_list, function(x) x$features))
  merged_geojson <- list(type = "FeatureCollection", features = merged_features)
  jsonlite::write_json(merged_geojson, output_file, auto_unbox = TRUE)
  message(paste("Merged GeoJSON saved to:", output_file))
}

#' Create Directory If Not Exist
#'
#' Creates a directory if it does not already exist.
#'
#' @param dir_path A character string representing the directory path.
create_dir_if_not_exist <- function(dir_path) {
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
decompress_gz_file <- function(input_file, output_file) {
  con <- gzfile(input_file, "rb")
  writeBin(readBin(con, raw(), n = 1e7), output_file)
  close(con)
  message(paste("Extracted:", input_file, "to", output_file))
}

# Example usage
# Define a bounding box (bbox) for a specific area
bbox <- c(xmin = 14.90546335395436, ymin = 4.275308778796507, xmax = 14.919215493755678, ymax = 4.283059290376294)

# Define the zoom level
zoom <- 9

# Convert the bounding box to a quadkey
quadkey <- bbox_to_quadkey(bbox, zoom)
print(paste("Generated Quadkey:", quadkey))

# Load the list of quadkeys from a CSV
list_quadkeys <- read.csv("https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", stringsAsFactors = FALSE)

# Download URLs by the generated quadkey
downloaded_files <- download_urls_by_quadkey(quadkey, list_quadkeys)

# Extract the downloaded files and convert them to GeoJSON format if applicable
extract_and_rename_as_geojson(downloaded_files)
# 
# # Merge all GeoJSON files into a single GeoJSON
# geojson_files <- list.files("data/bing/", pattern = "\\.geojson$", full.names = TRUE)
# # 
# # # Ensure jsonlite package is loaded
# # if (!"jsonlite" %in% (.packages())) {
# #   library(jsonlite)
# # }
# # 
# # merge_geojson_files(geojson_files, "data/merged_output.geojson")



# Ensure jsonlite package is loaded
if (!"jsonlite" %in% (.packages())) {
  library(jsonlite)
}

# Ensure sf package is loaded
if (!"sf" %in% (.packages())) {
  library(sf)
}

#' Convert Bounding Box to Quadkey
#'
#' This function converts a bounding box (bbox) to a quadkey at a specified zoom level.
#'
#' @param bbox A numeric vector containing xmin, ymin, xmax, ymax.
#' @param zoom An integer representing the zoom level.
#' @return A character string representing the quadkey.
#' @examples
#' bbox <- c(xmin = 14.9, ymin = 4.2, xmax = 14.91, ymax = 4.28)
#' zoom <- 9
#' bbox_to_quadkey(bbox, zoom)
#' @export
bbox_to_quadkey <- function(bbox, zoom) {
  tile_grid <- slippymath::bbox_to_tile_grid(bbox, zoom = zoom)
  tile_x <- tile_grid$tiles$x[1]
  tile_y <- tile_grid$tiles$y[1]
  
  quadkey <- quadkeyr::tileXY_to_quadkey(tile_x, tile_y, zoom)
  return(quadkey)
}

#' Download URLs by Quadkey
#'
#' This function downloads URLs corresponding to a given quadkey.
#'
#' @param quadkey A character string representing the quadkey.
#' @param list_quadkeys A data frame containing QuadKey and Url columns.
#' @param output_dir A character string representing the output directory path.
#' @return A character vector of downloaded file paths.
#' @examples
#' # Assuming list_quadkeys is loaded
#' quadkey <- "023112"
#' download_urls_by_quadkey(quadkey, list_quadkeys)
#' @export
download_urls_by_quadkey <- function(quadkey, list_quadkeys, output_dir = "data/bing/") {
  create_dir_if_not_exist(output_dir)
  
  url_values <- dplyr::filter(list_quadkeys, QuadKey == quadkey) %>% dplyr::pull(Url)
  
  if (length(url_values) == 0) {
    stop("No matching QuadKey found.")
  }
  
  downloaded_files <- purrr::map_chr(url_values, ~{
    file_name <- file.path(output_dir, basename(.x))
    httr::GET(.x, httr::write_disk(file_name, overwrite = TRUE))
    message(paste("Downloaded:", file_name))
    file_name
  })
  
  return(downloaded_files)
}
#' Extract Files from GZ
#'
#' Extracts .gz files from the downloaded files.
#'
#' @param downloaded_files A character vector of file paths.
#' @return A character vector of extracted file paths.
#' @export
extract_files_from_gz <- function(downloaded_files) {
  extracted_files <- purrr::map(downloaded_files, function(file) {
    if (grepl("\\.gz$", file)) {
      output_file <- tools::file_path_sans_ext(file)
      decompress_gz_file(file, output_file)
      return(output_file)
    } else {
      message(paste("Skipping non-gz file:", file))
      return(NULL)
    }
  })
  
  return(unlist(extracted_files))
}


#' Create Directory If Not Exist
#'
#' Creates a directory if it does not already exist.
#'
#' @param dir_path A character string representing the directory path.
create_dir_if_not_exist <- function(dir_path) {
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
}

#' Decompress GZ File
#'
#' Decompresses a .gz file using R.utils package.
#'
#' @param input_file A character string representing the .gz file path.
#' @param output_file A character string representing the output file path.
decompress_gz_file <- function(input_file, output_file) {
  R.utils::gunzip(input_file, destname = output_file, remove = TRUE, overwrite = TRUE)
  message(paste("Extracted:", input_file, "to", output_file))
}


# Example usage
# Define a bounding box (bbox) for a specific area
bbox <- c(xmin = 14.90546335395436, ymin = 4.275308778796507, xmax = 14.919215493755678, ymax = 4.283059290376294)

# Define the zoom level
zoom <- 9

# Convert the bounding box to a quadkey
quadkey <- bbox_to_quadkey(bbox, zoom)
print(paste("Generated Quadkey:", quadkey))

# Load the list of quadkeys from a CSV
list_quadkeys <- read.csv("https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", stringsAsFactors = FALSE)

# Download URLs by the generated quadkey
downloaded_files <- download_urls_by_quadkey(quadkey, list_quadkeys)

# Extract the downloaded files
extracted_files <- extract_files_from_gz(downloaded_files)

json_lines <-readLines(extracted_files[1])


# Read in the data line by line
# file_path <- "part-00047-eabb3dd8-62fd-4d80-9034-66c6a70f8018.c000.csv"
# json_lines <- readLines(file_path)

# Parse each line of the JSON into a list
features <- lapply(json_lines, fromJSON)

# Extract geometries and properties
geometries <- lapply(features, function(f) f$geometry)
properties <- lapply(features, function(f) f$properties)

# Convert geometries to SF objects
sf_features <- lapply(geometries, function(g) {
  # Check if g$coordinates has the correct structure and extract properly
  if (!is.null(g$coordinates) && length(g$coordinates) > 0) {
    
    # Ensure that the coordinates are a list of vectors
    coords_list <- g$coordinates[[1]]
    if (!is.list(coords_list)) {
      coords_list <- list(coords_list)  # Ensure it's a list
    }
    
    # Convert the list of coordinates to a matrix
    coords <- do.call(rbind, coords_list)
    
    # Validate that the resulting coordinates matrix has at least two columns
    if (is.matrix(coords) && ncol(coords) == 2) {
      return(st_polygon(list(coords)))
    } else {
      return(NULL)
    }
  } else {
    return(NULL)
  }
})

# Remove any NULL geometries (in case there were issues with some features)
sf_features <- sf_features[!sapply(sf_features, is.null)]

# Create an sf object from the geometries and properties
if (length(sf_features) > 0) {
  properties_df <- do.call(rbind, lapply(properties, as.data.frame))
  sf_object <- st_sf(properties_df, geometry = st_sfc(sf_features))
  
  # Print the sf object
  print(sf_object)
} else {
  print("No valid geometries found.")
}
# Remove any NULL geometries (in case there were issues with some features)
sf_features <- sf_features[!sapply(sf_features, is.null)]

# Create an sf object from the geometries and properties
if (length(sf_features) > 0) {
  properties_df <- do.call(rbind, lapply(properties, as.data.frame))
  sf_object <- st_sf(properties_df, geometry = st_sfc(sf_features))
  
  # Print the sf object
  print(sf_object)
} else {
  print("No valid geometries found.")
}

#' 
#' ######################3
#' # Load necessary libraries
#' library(sf)
#' library(dplyr)
#' library(jsonlite)
#' # Load necessary libraries
#' library(sf)
#' library(dplyr)
#' library(jsonlite)
#' 
#' #' Merge CSV Files into a Single GeoJSON
#' #'
#' #' This function reads multiple CSV files containing GeoJSON-like features, merges them,
#' #' and writes the result to a single GeoJSON file.
#' #'
#' #' @param input_files A character vector of file paths to the CSV files.
#' #' @param output_file A character string representing the output GeoJSON file path.
#' #' @param aoi_shape An optional sf object for filtering geometries within an Area of Interest (AOI).
#' #' @export
#' merge_geojson_files <- function(input_files, output_file, aoi_shape = NULL) {
#'   combined_sf <- NULL
#'   idx <- 0
#'   
#'   # Iterate through each file, read it, and append it to the combined object
#'   for (file in input_files) {
#'     # Read the CSV file with GeoJSON-like records
#'     features <- readLines(file) %>% lapply(fromJSON)
#'     features_df <- do.call(rbind.data.frame, features)
#'     
#'     # Ensure all columns have the same length by filling missing values with NA
#'     max_length <- max(sapply(features_df, length))
#'     features_df <- features_df %>% mutate(across(everything(), ~ if (length(.) < max_length) c(., rep(NA, max_length - length(.))) else .))
#'     
#'     # Convert to sf object
#'     geometries <- lapply(features_df$geometry, function(geom) {
#'       st_polygon(list(geom$coordinates))
#'     })
#'     
#'     sf_obj <- st_sf(
#'       features_df %>% dplyr::mutate_all(~if(is.list(.)) NA else .) %>% select(-geometry), # Remove the geometry column and handle lists
#'       geometry = st_sfc(geometries, crs = 4326) # Add geometry as an sf column
#'     )
#'     
#'     # Optionally filter using the AOI if provided
#'     if (!is.null(aoi_shape)) {
#'       sf_obj <- sf_obj[st_within(sf_obj, aoi_shape, sparse = FALSE), ]
#'     }
#'     
#'     # Update 'id' based on idx
#'     sf_obj$id <- seq(idx, idx + nrow(sf_obj) - 1)
#'     idx <- idx + nrow(sf_obj)
#'     
#'     # Combine with the existing sf object
#'     if (is.null(combined_sf)) {
#'       combined_sf <- sf_obj
#'     } else {
#'       combined_sf <- bind_rows(combined_sf, sf_obj)
#'     }
#'   }
#'   
#'   # Write the combined object to the output GeoJSON
#'   st_write(combined_sf, output_file, driver = "GeoJSON", delete_dsn = TRUE)
#' }
#' 
#' 
#' # Example usage
#' #input_files <- list.files(pattern = "\.csv$") # Get all CSV files
#' output_file <- "combined_output.geojson"
#' 
#' # Assuming you have an AOI shape (optional)
#' # aoi_shape <- st_read("path_to_aoi.geojson")
#' merge_geojson_files(extracted_files, output_file)  # Without AOI filter
#' # merge_geojson_files(input_files, output_file, aoi_shape)  # With AOI filter
