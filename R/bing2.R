#' 
#' # Ensure jsonlite package is loaded
#' if (!"jsonlite" %in% (.packages())) {
#'   library(jsonlite)
#' }
#' 
#' # Ensure sf package is loaded
#' if (!"sf" %in% (.packages())) {
#'   library(sf)
#' }
#' 
#' #' Convert Bounding Box to Quadkey
#' #'
#' #' This function converts a bounding box (bbox) to a quadkey at a specified zoom level.
#' #'
#' #' @param bbox A numeric vector containing xmin, ymin, xmax, ymax.
#' #' @param zoom An integer representing the zoom level.
#' #' @return A character string representing the quadkey.
#' #' @examples
#' #' bbox <- c(xmin = 14.9, ymin = 4.2, xmax = 14.91, ymax = 4.28)
#' #' zoom <- 9
#' #' bbox_to_quadkey(bbox, zoom)
#' #' @export
#' bbox_to_quadkey <- function(bbox, zoom) {
#'   tile_grid <- slippymath::bbox_to_tile_grid(bbox, zoom = zoom)
#'   tile_x <- tile_grid$tiles$x[1]
#'   tile_y <- tile_grid$tiles$y[1]
#'   
#'   quadkey <- quadkeyr::tileXY_to_quadkey(tile_x, tile_y, zoom)
#'   return(quadkey)
#' }
#' 
#' #' Download URLs by Quadkey
#' #'
#' #' This function downloads URLs corresponding to a given quadkey.
#' #'
#' #' @param quadkey A character string representing the quadkey.
#' #' @param list_quadkeys A data frame containing QuadKey and Url columns.
#' #' @param output_dir A character string representing the output directory path.
#' #' @return A character vector of downloaded file paths.
#' #' @examples
#' #' # Assuming list_quadkeys is loaded
#' #' quadkey <- "023112"
#' #' download_urls_by_quadkey(quadkey, list_quadkeys)
#' #' @export
#' download_urls_by_quadkey <- function(quadkey, list_quadkeys, output_dir = "data/bing/") {
#'   create_dir_if_not_exist(output_dir)
#'   
#'   url_values <- dplyr::filter(list_quadkeys, QuadKey == quadkey) %>% dplyr::pull(Url)
#'   
#'   if (length(url_values) == 0) {
#'     stop("No matching QuadKey found.")
#'   }
#'   
#'   downloaded_files <- purrr::map_chr(url_values, ~{
#'     file_name <- file.path(output_dir, basename(.x))
#'     httr::GET(.x, httr::write_disk(file_name, overwrite = TRUE))
#'     message(paste("Downloaded:", file_name))
#'     file_name
#'   })
#'   
#'   return(downloaded_files)
#' }
#' #' Extract Files from GZ
#' #'
#' #' Extracts .gz files from the downloaded files.
#' #'
#' #' @param downloaded_files A character vector of file paths.
#' #' @return A character vector of extracted file paths.
#' #' @export
#' extract_files_from_gz <- function(downloaded_files) {
#'   extracted_files <- purrr::map(downloaded_files, function(file) {
#'     if (grepl("\\.gz$", file)) {
#'       output_file <- tools::file_path_sans_ext(file)
#'       decompress_gz_file(file, output_file)
#'       return(output_file)
#'     } else {
#'       message(paste("Skipping non-gz file:", file))
#'       return(NULL)
#'     }
#'   })
#'   
#'   return(unlist(extracted_files))
#' }
#' 
#' 
#' #' Create Directory If Not Exist
#' #'
#' #' Creates a directory if it does not already exist.
#' #'
#' #' @param dir_path A character string representing the directory path.
#' create_dir_if_not_exist <- function(dir_path) {
#'   if (!dir.exists(dir_path)) {
#'     dir.create(dir_path, recursive = TRUE)
#'   }
#' }
#' 
#' #' Decompress GZ File
#' #'
#' #' Decompresses a .gz file using R.utils package.
#' #'
#' #' @param input_file A character string representing the .gz file path.
#' #' @param output_file A character string representing the output file path.
#' decompress_gz_file <- function(input_file, output_file) {
#'   R.utils::gunzip(input_file, destname = output_file, remove = TRUE, overwrite = TRUE)
#'   message(paste("Extracted:", input_file, "to", output_file))
#' }
#' 
#' 
#' # Example usage
#' # Define a bounding box (bbox) for a specific area
#' bbox <- c(xmin = 14.90546335395436, ymin = 4.275308778796507, xmax = 14.919215493755678, ymax = 4.283059290376294)
#' 
#' # Define the zoom level
#' zoom <- 9
#' 
#' # Convert the bounding box to a quadkey
#' quadkey <- bbox_to_quadkey(bbox, zoom)
#' print(paste("Generated Quadkey:", quadkey))
#' 
#' # Load the list of quadkeys from a CSV
#' list_quadkeys <- read.csv("https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", stringsAsFactors = FALSE)
#' 
#' # Download URLs by the generated quadkey
#' downloaded_files <- download_urls_by_quadkey(quadkey, list_quadkeys)
#' 
#' # Extract the downloaded files
#' extracted_files <- extract_files_from_gz(downloaded_files)
#' 
#' install.packages("geojsonio")
#' 
#' # Read each line as a separate JSON feature
#' lines <- readLines(extracted_files[1])
#' 
#' # Parse each line as JSON to create a list of features
#' features <- lapply(lines, fromJSON)
#' 
#' # Extract geometries and properties
#' geometries <- lapply(features, function(feature) {
#'   # Extract the coordinates and type
#'   geom_type <- feature$geometry$type
#'   coords <- feature$geometry$coordinates
#'   
#'   # Convert the coordinates into an sfc object
#'   st_geometry(st_as_sfc(list(type = geom_type, coordinates = coords), crs = 4326))
#' })
#' 
#' # Extract properties into a data frame
#' properties <- do.call(rbind, lapply(features, function(feature) {
#'   as.data.frame(feature$properties)
#' }))
#' 
#' # Create the sf object
#' geo_data <- st_sf(properties, geometry = st_sfc(geometries), crs = 4326)
#' 
#' # Check the geo_data
#' print(geo_data)
#' print(geo_data)