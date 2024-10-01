

#' Download OpenStreetMap Building Data
#'
#' This function downloads building data from OpenStreetMap (OSM) for a specified bounding box (bbox)
#' and saves it as a GeoJSON file. It queries the Overpass API for buildings within the given bbox
#' and retrieves the data in `sf` (simple features) format.
#'
#' @param bbox A numeric vector of length 4 representing the bounding box for the area of interest.
#'   The format should be: \code{c(min_lon, min_lat, max_lon, max_lat)}.
#' @param output_file A character string specifying the path to save the downloaded building data as a 
#'   GeoJSON file. Default is \code{"data/osm_buildings.geojson"}.
#'
#' @return A `sf` object containing the building polygons. Returns \code{NULL} if no building data is found.
#'
#' @details The function uses the \code{osmdata} package to query OpenStreetMap data via the Overpass API.
#'   It extracts building polygons that fall within the specified bounding box. The data is saved as a 
#'   GeoJSON file to the specified \code{output_file} path.
#'
#' @examples
#' \dontrun{
#' # Define a bounding box (e.g., around New York City)
#' bbox <- c(-74.25909, 40.477399, -73.700181, 40.917577)
#'
#' # Download the OSM building data and save it to a GeoJSON file
#' buildings <- download_osm_buildings(bbox, "nyc_buildings.geojson")
#' }
#'
#' @importFrom magrittr %>%
#' @importFrom osmdata opq add_osm_feature osmdata_sf
#' @importFrom sf st_write
#' @export
download_osm_buildings <- function(bbox, output_file = "data/osm_buildings.geojson") {
  # Validate bbox input
  if (length(bbox) != 4) {
    stop("The bbox parameter must be a numeric vector of length 4 in the format: c(min_lon, min_lat, max_lon, max_lat)")
  }

  # Create an Overpass API query for buildings within the bounding box
  osm_query <- opq(bbox = bbox) %>%
    add_osm_feature(key = "building")

  osm_data <- osmdata_sf(osm_query)
  building_data <- osm_data$osm_polygons

  if (nrow(building_data) == 0) {
    warning("No building data found for the specified bbox area.")
    return(NULL)
  }

  # Save the building data to a GeoJSON file
  st_write(building_data, output_file, delete_dsn = TRUE)
  message(sprintf("Building data successfully saved to '%s'", output_file))

  return(building_data)
}
