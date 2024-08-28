pacman::p_load(sf, raster, spatstat, tmap, tidyverse, devtools,sp)
library(maptools)
library(sp)
library(spatstat)
childcare_sf <- st_read("Hands-on_Exercise/Hands-on_Ex03/data/child-care-services-geojson.geojson")%>% 
  st_transform(crs =3414)
mpsz_sf <- st_read(dsn="Hands-on_Exercise/Hands-on_Ex03/data", layer="MP14_SUBZONE_WEB_PL")%>% 
  st_transform(crs =3414)
sg_sf<- st_read(dsn="Hands-on_Exercise/Hands-on_Ex03/data", layer="CostalOutline") %>% 
  st_transform(crs=3414)

tmap_mode("plot")
tm_shape(sg_sf) + 
  tm_polygons() + 
  tm_shape(childcare_sf) + 
  tm_dots()

tmap_mode('view') 
tm_shape(childcare_sf)+
  tm_dots()
tmap_mode('plot')

childcare_ppp <- as.ppp(st_coordinates(childcare_sf), st_bbox(childcare_sf))
plot(childcare_ppp)
summary(childcare_ppp)

any(duplicated(childcare_ppp))
multiplicity(childcare_ppp)

sum(multiplicity(childcare_ppp) > 1)

tmap_mode('view')
tm_shape(childcare_sf) + 
  tm_dots(alpha=0.4, size = 0.05)
tmap_mode('plot')

childcare_ppp_jit <- rjitter(childcare_ppp, 
                             retry=TRUE,
                             nsim=1, 
                             drop=TRUE)
any(duplicated(childcare_ppp_jit))


sg_owin <- as.owin(sg_sf)
plot(sg_owin)

summary(sg_owin)

childcareSG_ppp <- childcare_ppp[sg_owin]
childcareSG_ppp
plot(childcareSG_ppp)

kde_childcareSG_bw <- density(childcareSG_ppp, 
                              sigma=bw.diggle,
                              edge=TRUE,
                              kernel="gaussian")
bw <- bw.diggle(childcare_ppp)
bw

plot(kde_childcareSG_bw)

childcareSG_ppp.km <- rescale(childcareSG_ppp, 1000, "km")

kde_childcareSG.bw <- density(childcareSG_ppp.km, 
                              sigma=bw.diggle, 
                              edge=TRUE,
                              kernel="gaussian")
plot(kde_childcareSG.bw)

bw.CvL(childcareSG_ppp.km)
kde_childcareSG.bw.CvL <- density(childcareSG_ppp.km,
                                  sigma=bw.CvL,
                                  edge=TRUE,
                                  kernel="gaussian")
plot(kde_childcareSG.bw.CvL)


bw.scott(childcareSG_ppp.km)
kde_childcareSG.bw.scott <- density(childcareSG_ppp.km,
                                    sigma=bw.scott,
                                    edge=TRUE,
                                    kernel="gaussian")
plot(kde_childcareSG.bw.scott)

bw.ppl(childcareSG_ppp.km)
kde_childcareSG.bw.ppl <- density(childcareSG_ppp.km, sigma=bw.ppl, edge=TRUE, kernel="gaussian")
plot(kde_childcareSG.bw.ppl)

par(mfrow=c(2,2))
plot(kde_childcareSG.bw, main = "bw.diggle")
plot(kde_childcareSG.bw.CvL, main = "bw.CvL")
plot(kde_childcareSG.bw.scott, main = "bw.scott")
plot(kde_childcareSG.bw.ppl, main = "bw.ppl")

kde_childcareSG.gaussian <- density(childcareSG_ppp.km, 
                                    sigma=bw.ppl, 
                                    edge=TRUE, 
                                    kernel="gaussian")


kde_childcareSG.epanechnikov <- density(childcareSG_ppp.km, 
                                        sigma=bw.ppl, 
                                        edge=TRUE, 
                                        kernel="epanechnikov")

kde_childcareSG.quartic <- density(childcareSG_ppp.km, 
                                   sigma=bw.ppl, 
                                   edge=TRUE, 
                                   kernel="quartic")


kde_childcareSG.disc <- density(childcareSG_ppp.km, 
                                sigma=bw.ppl, 
                                edge=TRUE, 
                                kernel="disc")

par(mfrow=c(2,2))  
plot(kde_childcareSG.gaussian, main="Gaussian")
plot(kde_childcareSG.epanechnikov, main="Epanechnikov")
plot(kde_childcareSG.quartic, main="Quartic")
plot(kde_childcareSG.disc, main="Disc")

kde_childcareSG_600 <- density(childcareSG_ppp.km, sigma=0.6, edge=TRUE, kernel="gaussian")
plot(kde_childcareSG_600)

kde_childcareSG_adaptive <- adaptive.density(childcareSG_ppp.km, method="kernel")  
plot(kde_childcareSG_adaptive)

par(mfrow=c(1,2))
plot(kde_childcareSG.bw, main = "Fixed bandwidth")
plot(kde_childcareSG_adaptive, main = "Adaptive bandwidth")

matrix_kde <- as.matrix(kde_childcareSG.bw)
sp_pixels <- SpatialPixelsDataFrame(
  points = expand.grid(x = 1:ncol(matrix_kde), y = 1:nrow(matrix_kde)),
  data = data.frame(value = as.vector(matrix_kde))
)

sp_grid <- as(sp_pixels, "SpatialGridDataFrame")
library(lattice)
ssplot(sp_grid,"value")

gridded_kde_childcareSG_bw <- as.im.RasterLayer(kde_childcareSG.bw)
spplot(gridded_kde_childcareSG_bw)
