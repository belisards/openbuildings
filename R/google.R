# Google Open Buildings Functions

#' Get the Google Open Buildings Region Code
#' @param centroid A numeric vector representing the centroid coordinates in the format \code{c(lon, lat)}.
#' @return A character string representing the S2 region code.
get_open_buildings_region_code <- function(centroid) {
  s2_cell <- s2::as_s2_cell(s2::s2_lnglat(centroid[1], centroid[2]))
  s2_id <- as.character(s2::s2_cell_parent(s2_cell, level = 4))
  region_code <- substr(s2_id, 1, 3)
  return(region_code)
}

#' Download Google Open Buildings Data
download_google_open_buildings <- function(bbox, output_dir = "data/", delete_compressed = TRUE) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Calculate the centroid from bbox
  centroid <- c(mean(c(bbox[1], bbox[3])), mean(c(bbox[2], bbox[4])))
  region_code <- get_open_buildings_region_code(centroid)

  download_and_uncompress_buildings_data(region_code, output_dir, delete_compressed)
  all_data <- load_all_buildings_data(output_dir)

  return(all_data)
}

#' Download and Uncompress Google Open Buildings Data
download_and_uncompress_buildings_data <- function(region_code, output_dir, delete_compressed) {
  url <- sprintf("https://storage.googleapis.com/open-buildings-data/v3/polygons_s2_level_4_gzip/%s_buildings.csv.gz", region_code)
  compressed_file_path <- file.path(output_dir, sprintf("%s_buildings.csv.gz", region_code))
  uncompressed_file_path <- file.path(output_dir, sprintf("%s_buildings.csv", region_code))

  download.file(url, compressed_file_path, mode = "wb")
  print("File downloaded. Uncompressing it...")
  R.utils::gunzip(compressed_file_path, destname = uncompressed_file_path, overwrite = TRUE)

  if (delete_compressed && file.exists(compressed_file_path)) {
    unlink(compressed_file_path)
  }
}

# Load all buildings data from CSV files
load_all_buildings_data <- function(data_folder) {
  file_list <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)
  if (length(file_list) == 0) {
    stop("No CSV files found in the specified folder.")
  }
  all_data <- do.call(rbind, lapply(file_list, sf::read_sf))
  return(all_data)
}
