# Required packages
# Install these packages if you haven't already
install.packages("sf")
install.packages("geojsonsf")
install.packages("dplyr")
install.packages("httr")
install.packages("jsonlite")
install.packages("slippymath")

library(sf)
library(geojsonsf)
library(dplyr)
library(httr)
library(jsonlite)
library(slippymath)

# Step 1 - Define our area of interest (AOI)
bbox <- c(xmin = 14.90546335395436, ymin = 4.275308778796507, xmax = 14.919215493755678, ymax = 4.283059290376294)
aoi_geom <- st_as_sfc(st_bbox(bbox, crs = st_crs(4326)))



# Step 2 - Determine which tiles intersect our AOI
# Using the 'slippymath' package to get tiles
tile_grid <- slippymath::bbox_to_tile_grid(bbox, zoom = 9)
tiles <- tile_grid$tiles
quad_keys <- unique(sapply(tiles, function(tile) paste0(tile[3], '-', tile[1], '-', tile[2])))
cat("The input area spans", length(quad_keys), "tiles: ", paste(quad_keys, collapse=", "), "\n")


# Step 3 - Download the building footprints for each tile that intersects our AOI and crop the results
# Load dataset of URLs
df <- read.csv("https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv", stringsAsFactors = FALSE)

combined_gdf <- st_sf(geometry = st_sfc()) # Empty GeoDataFrame with empty geometry column

for (quad_key in quad_keys) {
  rows <- filter(df, QuadKey == quad_key)
  if (nrow(rows) == 1) {
    url <- rows$Url[1]
    
    # Download and parse JSON
    response <- httr::GET(url)
    stop_for_status(response)
    json_content <- content(response, as = "text")
    df2 <- jsonlite::fromJSON(json_content, flatten = TRUE)
    
    # Convert to sf object
    df2_sf <- geojson_sf(json_content)
    df2_sf <- st_set_crs(df2_sf, 4326)
    
    # Filter geometries within the AOI
    df2_sf <- df2_sf %>% filter(st_within(geometry, aoi_geom, sparse = FALSE))
    
    combined_gdf <- rbind(combined_gdf, df2_sf)
  } else if (nrow(rows) > 1) {
    stop(paste("Multiple rows found for QuadKey:", quad_key))
  } else {
    stop(paste("QuadKey not found in dataset:", quad_key))
  }
}

# Step 4 - Save the resulting footprints to file
st_write(combined_gdf, "example_building_footprints.geojson", driver = "GeoJSON")

# -------------
# library(AzureStor)
# library(rstac)
# library(magrittr)
# library(sf)
# 
# # Perform the STAC search with a custom download function for S3
# s_obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1/") %>%
#   stac_search(collections = "ms-buildings", 
#               bbox = c(14.90546335395436, 4.275308778796507, 14.919215493755678, 4.283059290376294)) %>%
#   get_request()
# 
# assets = s_obj %>% 
#   assets_download(
#     overwrite = TRUE,
#     download_fn = \(asset) {
#       out_file <- httr::parse_url(asset$href)$path
#       out_file <- file.path(getwd(), "data", out_file)
#       out_dir <- dirname(out_file)
#       if (!dir.exists(out_dir))
#         dir.create(out_dir, recursive = TRUE)
#       stopifnot(dir.exists(out_dir))
#       if (!file.exists(out_file))
#         sf::gdal_utils(
#           util = "translate",
#           source = asset$href,
#           destination = out_file,
#           quiet = TRUE
#         )
#       asset$href <- out_file
#       return(asset)
#     }
#   )
# 
# assets
# 
# library(jsonlite)
# library(arrow)
# # Load the JSON content
# item_json <- fromJSON("data/item.json")
# 
# # Inspect the structure (Optional)
# str(item_json)
# 
# 
# #########3
# 
# # library(magrittr)
# # library(rstac)
# # 
# # stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
# #   stac_search(collections = "CB4-16D-2",
# #               datetime = "2019-06-01/2019-08-01",
# #               limit=1) %>%
# #   stac_search() %>%
# #   get_request() %>%
# #   assets_download(asset_names = "thumbnail", output_dir = "data/")
# ###########
# 
# 
# # Perform the STAC search
# s_obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1/") %>%
#   stac_search(collections = "ms-buildings", 
#               bbox = c(14.90546335395436, 4.275308778796507, 14.919215493755678, 4.283059290376294)) %>%
#   get_request() 
# 
# s_obj %>% assets_download(overwrite=TRUE)
# 
# # Extract the features (list of items)
# items <- s_obj$features
# items
