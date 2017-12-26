

library(exifr)
library(dplyr)
library(sf)


setwd("Desktop/104NIKON/")

# Get all paths to photos
f <- list.files(path = ".",
                pattern = "*.jpg$", 
                full.names = T, 
                ignore.case = T); f

# Read tags of photos
fl <- sapply(f, read_exif, tags = c("FileName", 
                                    "GPSMapDatum", 
                                    "GPSDateTime", 
                                    "GPSLatitude", 
                                    "GPSLongitude", 
                                    "GPSImgDirectionRef", 
                                    "GPSImgDirection")); fl

# Select only images with GPS tags and bring them to a sigle dataframe
idx <- sapply(fl, function(x) {
  any(names(x) == "GPSDateTime") &&
    any(names(x) == "GPSLatitude") && 
    any(names(x) == "GPSLatitude") &&
    any(names(x) == "GPSImgDirection")
}); idx
fl <- fl[idx]; fl
d <- do.call(rbind, fl); d

# Converst dataframe to simplefeature
sf <- st_as_sf(x = d, 
               coords = c("GPSLongitude", "GPSLatitude"), 
               crs = 4326)

# Export to shapefile
st_write(obj = sf, 
         layer = "mappoints.shp", 
         dsn = "mappoints.shp", 
         driver = "ESRI Shapefile", 
         delete_layer = T)

