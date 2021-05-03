#Rcode to regrid the VICSoildata into required resolution. Data format must be .nc
#RajtantraLilhare@UNBC, Prince George, BC Canada

rm(list = ls())
cat("\014")
library(ncdf4)
library(rgdal)
library(raster)
library(reshape2)
library(plyr)
library(dplyr)
library(SDMTools) # to covert ascii to dataframe and viceverca

# ascii_text regridding --------------------------------------------------------

# ascii REGRIDDING
#Data
asc<-read.csv("soil_NRB1_0_25.csv") ##Input raw (default) VIC soil here in this formate #Lat #Lon #param1,2,3,4...........
head(asc)
latlon<-asc[,c(1,2)]
head(latlon)
ascd<-asc[,c(3:length(asc))]
head(ascd)
ncol(asc)
length(asc)
#Function to convert text files to ascii

txt2ascii<-function(x){
    #required SDMTools
    vv2<-ascd[,x]  
    head(vv2)
    dfx<-cbind(latlon,vv2)
    head(dfx)
    df_asc<-dataframe2asc(dfx,file=paste0(x,"ascii"))
    #dataframe2asc(dfx,file=paste0("ascii_",x))
    #assign(paste0("ascii_",x),dfx,envir = .GlobalEnv)
    #assign(paste0("df_ascii_",x),df_asc,envir = .GlobalEnv)
    return(dfx)
}

for ( i in 1:49){     #Here define number of colomn of raw soil file except lat lon colomn
  txt2ascii(i)
}

# read ascii as stacked layer and brick them
rrr<-(list.files(pattern = ".asc$"))
rrr
r4<-rrr[order(as.numeric(sub("([0-9]*).*", "\\1", rrr)))]
r4


r<-stack(r4)
r

rr<-brick(r, values=TRUE)
dim(rr)
plot(rr,10)

# For regrid
#find the extent
#ext<-extent(min(latlon$Lon),max(latlon$Lon),min(lat lon$Lat),max(lat lon$Lat))
ext<-extent(-127.9250,-122.575,52.7750,56.975) 																		#define your raw soil file extent
ext
#define new blank raster with desired resolution and defined extent
de.ras<-raster(ext,crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0", resolution=0.05, vals=NULL) 	#Define new resoln here
de.ras
#Resample data into desired grids as defined above
r.new<-resample(rr,de.ras,method="ngb",crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") 						# define interpolation here like bilinear or any other
plot(r.new,10)
dim(r.new)
r.new


# Write high resoultion raster as new cdf
#writeRaster(r.new, filename='soil_nelson.nc', format="CDF",bylayer=F, suffix='numbers',varname="variables",varunit="varunits",
            #longname="varlongname",xname= "Lat", yname="Lon",zname="variable",zunit="varriable",
            #overwrite=TRUE) 
##this is optional


#Write as ascii
writeRaster(r.new, filename='soil_nelson', format="ascii",bylayer=T, suffix='numbers',varname="variables",varunit="varunits",
            longname="varlongname",xname= "Lat", yname="Lon",zname="variable",zunit="varriable",
            overwrite=TRUE)  


# Reverse ascii to text
ascfiles<-(list.files(pattern = "soil_nelson"))
ascfiles

#  astx<-"soil_nelson_5.asc"
#  as2tx<-asc2dataframe(astx)
#  colnames(as2tx)<-c("Lat","Lon",paste0("var",substr("soil_nelson_5.asc",13,14)))
#  head(as2tx) 

 cbind.fill <- function(...){
  nm <- list(...) 
  nm <- lapply(nm, as.matrix)
  n <- max(sapply(nm, nrow)) 
  do.call(cbind, lapply(nm, function (x) 
    rbind(x, matrix(, n-nrow(x), ncol(x))))) 
}

ascii2txt<-function(x){
  #required SDMTools
  astx<-x
  as2tx<-asc2dataframe(astx)
  colnames(as2tx)<-c("Lat","Lon",paste0("Var",substr(x,13,14)))
  head(as2tx) 
  assign(paste0("Var",substr(x,13,14)),as2tx,envir = .GlobalEnv)
 return(as2tx)
}

as2df<-lapply(ascfiles,ascii2txt)
class(as2df)
as2dff<-do.call(cbind.fill,as2df)
head(as2dff)
class(as2dff)
mt2df<-melt(as.data.frame(as2dff),id=c("Lat","Lon"))
head(mt2df)
tail(mt2df)
fnldf<-dcast(mt2df,Lat+Lon~variable,value.var="value")
head(fnldf)

write.csv(fnldf,file="Soil_NRB_0.05.csv") #your output regridded file
#after getting this file user must rearrange colomn (1,2,3,4.....) in the Soil_NRB_0.05.csv file and convert the .csv file to .txt to run the VIC model                   

