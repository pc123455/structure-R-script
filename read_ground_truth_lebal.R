library(R.matlab)
setwd("F:\\struction detection")

path<-getwd()

#ground truth time
music.boundary.ground.time<-readMat(file.path(path,"ground_truth_v7.mat"))
music.boundary.ground.time<-music.boundary.ground.time[[1]]

#ground truth label
music.boundary.ground.label<-readMat(file.path(path,"ground_truth_label_v7.mat"))
music.boundary.ground.label<-music.boundary.ground.label[[1]]

for(i in 1:length(music.boundary.ground.label)){
  music.boundary.ground.label[[i]]<-music.boundary.ground.label[[i]][[1]]
}


