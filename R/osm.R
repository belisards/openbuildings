# OpenStreetMap Functions

#' Download OSM Building Data
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
