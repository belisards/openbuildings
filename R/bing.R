# Load necessary libraries
library(httr)
library(sf)
library(jsonlite)

#' Download Bing Open Buildings Data
#'
#' This function downloads building data from the Bing Open Buildings dataset using a bounding box.
#'
#' @param bbox A numeric vector representing the bounding box coordinates in the format \code{c(min_lon, min_lat, max_lon, max_lat)}.
#' @param output_file The file path where the Bing data should be saved (default is \code{"bing_buildings.geojson"}).
#' @return A \code{sf} object containing building geometries within the specified bbox.
#' @export
#' @examples
#' \dontrun{
#' bbox <- c(14.90546335395436, 4.275308778796507, 14.919215493755678, 4.283059290376294)
#' download_bing_open_buildings(bbox, output_file = "bing_buildings.geojson")
#' }
download_bing_open_buildings <- function(bbox, output_file = "bing_buildings.geojson") {
  # Validate bbox input
  if (length(bbox) != 4) {
    stop("The bbox parameter must be a numeric vector of length 4 in the format: c(min_lon, min_lat, max_lon, max_lat)")
  }
  
  # Construct the URL to access Bing Open Buildings data
  # For this example, we'll use a hypothetical API endpoint since Bing's data would be accessed via Planetary Computer or similar service.
  # Replace <API_KEY> with your actual API key or access token if required.
  # Note: The actual URL may differ based on the data source; you might need to adjust accordingly.
  url <- sprintf("https://example-bing-buildings-api.com/data?bbox=%f,%f,%f,%f&format=geojson",
                 bbox[1], bbox[2], bbox[3], bbox[4])
  
  # Send GET request to download data
  response <- httr::GET(url)
  
  # Check if the request was successful
  if (response$status_code != 200) {
    stop(sprintf("Failed to download Bing Open Buildings data. HTTP status code: %d", response$status_code))
  }
  
  # Parse the downloaded GeoJSON data
  geojson_data <- content(response, "text", encoding = "UTF-8")
  
  # Write the raw GeoJSON data to a file
  writeLines(geojson_data, output_file)
  
  # Read the GeoJSON file as an sf object
  building_data <- sf::st_read(output_file, quiet = TRUE)
  
  if (nrow(building_data) == 0) {
    warning("No building data found for the specified bbox area.")
    return(NULL)
  }
  
  message(sprintf("Building data successfully saved to '%s'", output_file))
  
  return(building_data)
}
