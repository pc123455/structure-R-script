library(R.matlab)
setwd("C:\\Users\\xwy\\Desktop\\struction detection")

path<-getwd()

#detected boundary
music.boundary.time<-readMat(file.path(path,"best_boundary.mat"))
music.boundary.time<-music.boundary.time[[1]]

#extracted plp features & music duration
plp_features<-readMat(file.path(path,"plp_features_just_plp_v7.mat"))

#music length
music.length<-readMat(file.path(path,"music_length.mat"))
music.length<-music.length[[1]]

music.feature.plp<-list()
music.feature.spec<-list()

#seperate features
for(i in 1:length(plp_features[[1]])){
  temp<-plp_features[[1]]
  temp<-temp[[i]]
  temp<-temp[[1]]
  music.feature.plp[[i]]<-temp[[1]][[1]]
  music.feature.spec[[i]]<-temp[[2]][[1]]
}






