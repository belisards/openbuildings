# Google Open Buildings Functions

#' Get the Google Open Buildings Region Code
#' @param centroid A numeric vector representing the centroid coordinates in the format \code{c(lon, lat)}.
#' @return A character string representing the S2 region code.
#' 
get_open_buildings_region_code <- function(centroid) {
  s2_cell <- s2::as_s2_cell(s2::s2_lnglat(centroid[1], centroid[2]))
  s2_id <- as.character(s2::s2_cell_parent(s2_cell, level = 4))
  region_code <- substr(s2_id, 1, 3)
  return(region_code)
}

#' Download Google Open Buildings Data
#'
#' @description Downloads Google Open Buildings data for a specified bounding box (bbox).
#' If the data file already exists in the specified output directory, the download is skipped.
#'
#' @param bbox Numeric vector of length 4 specifying the bounding box in the format c(min_lon, min_lat, max_lon, max_lat).
#' @param output_dir Character string specifying the output directory where the data will be saved. Defaults to "data/".
#' @param delete_compressed Logical, if TRUE, deletes the compressed file after uncompressing. Defaults to TRUE.
#'
#' @return Character string representing the filename of the downloaded (or existing) data file.
#'
#' @examples
#' bbox <- c(36.80, -1.30, 36.90, -1.20)
#' download_google_open_buildings(bbox)
#'
#' @export
#' 
download_google_open_buildings <- function(bbox, output_dir = "data", delete_compressed = TRUE) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Get the centroid from bbox
  centroid <- c(mean(c(bbox[1], bbox[3])), mean(c(bbox[2], bbox[4])))
  region_code <- get_open_buildings_region_code(centroid)
  
  # Construct the filename
  file_name <- file.path(output_dir, sprintf("%s_buildings.csv", region_code))
  compressed_file_name <- file.path(output_dir, sprintf("%s_buildings.csv.gz", region_code))
  
  # Skip download if the file already exists in CSV or compressed
  # exist_condition <- 
# if (!file.exists(file_name)) {
#   if (!file.exists(compressed_file_name)) {
#     url <- sprintf("https://storage.googleapis.com/open-buildings-data/v3/polygons_s2_level_4_gzip/%s_buildings.csv.gz", region_code)
#     
#     # Download file with error handling
#     tryCatch({
#       download.file(url, compressed_file_name, mode = "wb")
#       message("File downloaded.")
#     }, error = function(e) {
#       stop(sprintf("Failed to download the file: %s", e$message))
#     })
#   } else {
#     message("Compressed file already exists. Skipping download.")
#   }
# 
#   # Stream decompression directly to the destination file
#   message("gunzip - Uncompressing the file...")
#   tryCatch({
#     # R.utils::gunzip(compressed_file_name, destname = file_name, overwrite = TRUE)
#     system(sprintf("gunzip -c %s > %s", compressed_file_name, file_name))
#   }, error = function(e) {
#     stop(sprintf("Failed to uncompress the file: %s", e$message))
#   })
#   
#   if (delete_compressed && file.exists(compressed_file_name)) {
#     unlink(compressed_file_name)
#   }
# } else {
#   message("File already exists. Skipping download.")
#   return(file_name)
  if (!file.exists(file_name)) {
    if (!file.exists(compressed_file_name)) {
      url <- sprintf("https://storage.googleapis.com/open-buildings-data/v3/polygons_s2_level_4_gzip/%s_buildings.csv.gz", region_code)
      
      # Download file with error handling
      tryCatch({
        download.file(url, compressed_file_name, mode = "wb")
        message("File downloaded.")
      }, error = function(e) {
        stop(sprintf("Failed to download the file: %s", e$message))
      })
    } else {
      message("Compressed file already exists. Skipping download.")
    }
    
    # Stream decompression directly to the destination file
    message("gunzip - Uncompressing the file...")
    tryCatch({
      # R.utils::gunzip(compressed_file_name, destname = file_name, overwrite = TRUE)
      system(sprintf("gunzip -c %s > %s", compressed_file_name, file_name))
    }, error = function(e) {
      stop(sprintf("Failed to uncompress the file: %s", e$message))
    })
    
    if (delete_compressed && file.exists(compressed_file_name)) {
      unlink(compressed_file_name)
    }
  } else {
    message("File already exists. Skipping download.")
    return(file_name)
  }
  
}


# 
# # Load all buildings data from CSV files
# load_all_buildings_data <- function(data_folder) {
#   file_list <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)
#   if (length(file_list) == 0) {
#     stop("No CSV files found in the specified folder.")
#   }
#   all_data <- do.call(rbind, lapply(file_list, sf::read_sf))
#   return(all_data)
# }
