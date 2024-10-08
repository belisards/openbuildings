% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_buildings.R
\name{download_osm_buildings}
\alias{download_osm_buildings}
\title{Download OSM Building Data}
\usage{
download_osm_buildings(centroid, output_file = "osm_buildings.geojson")
}
\arguments{
\item{centroid}{A numeric vector representing the centroid coordinates in the format \code{c(lon, lat)}.}

\item{output_file}{The file path where the OSM data should be saved (default is \code{"osm_buildings.geojson"}).}
}
\value{
A \code{sf} object containing building geometries from OSM within the specified area.
}
\description{
This function downloads building data from OpenStreetMap within a small buffer area around the given centroid.
}
\examples{
\dontrun{
download_osm_buildings(c(4.35, 50.85), "osm_buildings.geojson")
}
}
