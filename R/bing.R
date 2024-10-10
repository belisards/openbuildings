# Perform the STAC search with a custom download function for S3
s_obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1/") %>%
  stac_search(collections = "ms-buildings", 
              bbox = c(14.90546335395436, 4.275308778796507, 14.919215493755678, 4.283059290376294)) %>%
  get_request()

assets = s_obj %>% 
  assets_download(
    overwrite = TRUE,
    download_fn = \(asset) {
      out_file <- httr::parse_url(asset$href)$path
      out_file <- file.path(getwd(), "data", out_file)
      out_dir <- dirname(out_file)
      if (!dir.exists(out_dir))
        dir.create(out_dir, recursive = TRUE)
      stopifnot(dir.exists(out_dir))
      if (!file.exists(out_file))
        sf::gdal_utils(
          util = "translate",
          source = asset$href,
          destination = out_file,
          quiet = TRUE
        )
      asset$href <- out_file
      return(asset)
    }
  )

library(jsonlite)
library(arrow)
# Load the JSON content
item_json <- fromJSON("data/item.json")

# Inspect the structure (Optional)
str(item_json)


#########3

# library(magrittr)
# library(rstac)
# 
# stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
#   stac_search(collections = "CB4-16D-2",
#               datetime = "2019-06-01/2019-08-01",
#               limit=1) %>%
#   stac_search() %>%
#   get_request() %>%
#   assets_download(asset_names = "thumbnail", output_dir = "data/")
###########
library(AzureStor)
library(rstac)
library(magrittr)
library(sf)

# Perform the STAC search
s_obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1/") %>%
  stac_search(collections = "ms-buildings", 
              bbox = c(14.90546335395436, 4.275308778796507, 14.919215493755678, 4.283059290376294)) %>%
  get_request() 

s_obj %>% assets_download(overwrite=TRUE)

# Extract the features (list of items)
items <- s_obj$features
items
