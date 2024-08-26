#LIDAR System to create a DTM 
library(stars)
library(ggplot2)
library(sf)
library(dplyr)
dtm_harv <- read_stars("DataCarpentry/data/harv/harv_dtmcrop.tif")
dsm_harv <- read_stars("DataCarpentry/data/harv/harv_dsmcrop.tif")

#lesson 2 - mathematical operations with Raster Data 
chm_harv <- dsm_harv - dtm_harv


ggplot() + 
  geom_stars(data = chm_harv)

#lesson 3 - introduction to vector data 
plots_harv <- st_read("DataCarpentry/data/harv/harv_plots.shp")
boundary_harv <- st_read("DataCarpentry/data/harv/harv_boundary.shp")

#colouring the points based on the plot type
#aading the boundary 
ggplot() + 
  geom_sf(data = boundary_harv, alpha = 0.5) + 
  geom_sf(data = plots_harv, 
          mapping = aes(color = plot_type)) 
  
#lesson 4 - projections (different coordinate systems / projections )
#graph plots on top of raster 
ggplot() + 
  geom_stars(data = dtm_harv) + 
  geom_sf(data = plots_harv)

st_crs(dtm_harv)
st_crs(plots_harv) 
#trasnforming to a single projection - st_transform 
dtm_harv_lat_long <- st_transform(dtm_harv, 4326)
st_crs(dtm_harv_lat_long)

#the easiest thing to do is to match to an existing coordinate system 
#transform plots data to crs of vector data
plots_harv_utm <- st_transform(plots_harv, st_crs(dtm_harv))

#plot
ggplot() + 
  geom_stars(data = dtm_harv)+
  geom_sf(data = plots_harv_utm)


#what is the best crs to work with for a project 
#utm is the most commonly used and appropriate for ecological research 
#not really suitable for large scale research (dealing with multiple zones)

#lesson 5 - extracting raster data at points 

plots_harv_utm <- st_transform(plots_harv, st_crs(dtm_harv))

#aggregate
plot_elevations <- aggregate(dtm_harv, plots_harv_utm, mean,as_points = FALSE)
plot_elevations$harv_dtmcrop.tif #results are the 7 elevations matched to each row of the plots_harv_dtm

#mutate function 
mutate(plots_harv_utm, elevations = plot_elevations$harv_dtmcrop.tif)

#method 2 
plots_harv_utm$elevations <- plot_elevations$harv_dtmcrop.tif


#lesson 6 -  mapping polygons based on their properties 
library(sf)
library(ggplot2)
harv_soils <- st_read("DataCarpentry/data/harv/harv_soils.shp")
ggplot() + 
  geom_sf(data = harv_soils, 
          mapping = aes(fill = TYPE_)) + 
  scale_fill_viridis_d()

#subplot for each soil type 
ggplot() + 
  geom_sf(data = harv_soils) +
  facet_wrap(~TYPE_)


#lesson 7 - aggregating raster data inside of polygons 
library(sf)
library(stars)
library(ggplot2)
library(dplyr)
harv_soils <- st_read("DataCarpentry/data/harv/harv_soils.shp")
harv_dtm <- read_stars("DataCarpentry/data/harv/harv_dtmfull.tif")

ggplot() + 
  geom_stars(data = harv_dtm)+
  geom_sf(data = harv_soils, alpha = 0.2)


#average elevation in each soil polygon
#similar to group_by
elevs_by_soil <- aggregate(harv_dtm, harv_soils, mean)
elevs_by_soil$harv_dtmfull.tif

harv_soils <- mutate(harv_soils, elevation = elevs_by_soil$harv_dtmfull.tif)

#plotting
ggplot()+ 
  geom_sf(data = harv_soils, mapping = aes(fill = elevation)) + 
  scale_fill_viridis_c()


#lesson 8 -  maintaining projections when plotting with ggpplot
#sf , stars, ggplot2, dplyr libraries 
harv_soils <- st_read("DataCarpentry/data/harv/harv_soils.shp")
harv_dtm <- read_stars("DataCarpentry/data/harv/harv_dtmfull.tif")

st_crs(harv_soils)
st_crs(harv_dtm)

ggplot() + 
  geom_stars(data = harv_dtm)+ 
  geom_sf(data = harv_soils, alpha = 0)+
  coord_sf(datum = st_crs(harv_soils))

#utm northings & eastings are gone, replaced by 
#lng and lat, which is changed by default by geom_sf

#use coord_sf function to prevent this 

#lesson 9 - creating vector point data from tabular data 
library(sf)
harv_plots <- st_read("DataCarpentry/data/harv/harv_plots.csv", 
                      options = c("X_POSSIBLE_NAMES=longtitude", 
                                  "Y_POSSIBLE_NAMES=latitude"),
                      crs = 4326)
st_write(harv_plots, "harv_plots_new.shp")

#lesson 10 - cropping data
library(sf)
library(stars)
library(ggplot2)

harv_boundary <- st_read("DataCarpentry/data/harv/harv_boundary.shp")
harv_dtm <- read_stars("DataCarpentry/data/harv/harv_dtmfull.tif")
harv_soils <- st_read("DataCarpentry/data/harv/harv_soils.shp")

ggplot() + 
  geom_stars(data = harv_dtm) + 
  scale_fill_viridis_c() + 
  geom_sf(data = harv_boundary, alpha = 0.2)
  
#use stcrop to get rid of the useless parts
harv_dtm_cropped <- st_crop(harv_dtm, harv_boundary)
harv_dtm
harv_dtm_cropped


ggplot() + 
  geom_stars(data = harv_dtm_cropped) + 
  scale_fill_viridis_c(na.value = "transparent") + 
  geom_sf(data = harv_boundary, alpha = 0.2)

#masking data -- keep the full set of data as opposed to cropping it smaller 
#harv_dtm_cropped <- st_crop(harv_dtm, harv_boundary, crop = FALSE)

#crop to a bounding box -- using st crop; pass a square region instead of polygon 
ggplot() + 
  geom_stars(data = harv_dtm_cropped) + 
  scale_fill_viridis_c(na.value = "transparent") + 
  geom_sf(data = harv_boundary, alpha = 0.2) + 
  coord_sf(datum = st_crs(harv_boundary))

bbox <- st_bbox(c(xmin = 731000, ymin = 4713000, xmax = 732000, ymax = 4714000), 
                crs = st_crs(harv_dtm))

harv_dtm_small <- st_crop(harv_dtm, bbox)
harv_soils_small <- st_crop(harv_soils, bbox)


ggplot() + 
  geom_stars(data = harv_dtm_small) + 
  scale_fill_viridis_c() + 
  geom_sf(data = harv_soils_small, alpha = 0.5)


#lesson 11 - saving / writing spatial data
#write and read functions 

write_stars(harv_dtm_cropped, "harv_dtm_cropped.tif")
read_stars("harv_dtm_cropped.tif")


st_write(harv_soils_small, "harv_soils_small.shp")
