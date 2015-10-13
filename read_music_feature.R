library(R.matlab)
setwd("F:\\struction detection")

path<-getwd()

#detected boundary
music.boundary.time<-readMat(file.path(path,"best_boundary.mat"))
music.boundary.time<-music.boundary.time[[1]]

#extracted plp features & music duration of left channel
plp_features.left<-readMat(file.path(path,"plp_features_just_plp_v7.mat"))

#extracted plp features & music duration of right channel
plp_features.right<-readMat(file.path(path,"plp_features_just_plp_right_v7.mat"))

#music length
music.length<-readMat(file.path(path,"music_length.mat"))
music.length<-music.length[[1]]

for(i in 1:length(music.boundary.time)){
  cur_boundary_time<-music.boundary.time[[i]][[1]]
  cur_boundary_time[[length(cur_boundary_time)+1]]<-music.length[i]
  music.boundary.time[[i]]<-cur_boundary_time
}

music.feature.plp.left<-list()
music.feature.spec.left<-list()

#seperate features of left channel
for(i in 1:length(plp_features.left[[1]])){
  temp<-plp_features.left[[1]]
  temp<-temp[[i]]
  temp<-temp[[1]]
  music.feature.plp.left[[i]]<-temp[[1]][[1]]
  music.feature.spec.left[[i]]<-temp[[2]][[1]]
}


music.feature.plp.right<-list()
music.feature.spec.right<-list()

#seperate features of right channel
for(i in 1:length(plp_features.right[[1]])){
  temp<-plp_features.right[[1]]
  temp<-temp[[i]]
  temp<-temp[[1]]
  music.feature.plp.right[[i]]<-temp[[1]][[1]]
  music.feature.spec.right[[i]]<-temp[[2]][[1]]
}

