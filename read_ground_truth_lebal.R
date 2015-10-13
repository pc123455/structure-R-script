library(R.matlab)
setwd("F:\\struction detection")

path<-getwd()

#ground truth time
music.boundary.ground.time<-readMat(file.path(path,"ground_truth_v7.mat"))
music.boundary.ground.time<-music.boundary.ground.time[[1]]

for(i in 1:length(music.boundary.ground.time)){
  music.boundary.ground.time[[i]]<-music.boundary.ground.time[[i]][[1]]
}

#ground truth label
music.boundary.ground.label<-readMat(file.path(path,"ground_truth_label_v7.mat"))
music.boundary.ground.label<-music.boundary.ground.label[[1]]

for(i in 1:length(music.boundary.ground.label)){
  cur_label<-music.boundary.ground.label[[i]]
  new_label<-list()
  for(j in 1:length(cur_label[[1]])){
    new_label[[j]]<-cur_label[[1]][[j]][[1]][[1]]
  }
  music.boundary.ground.label[[i]]<-new_label
}

#ground truth type
music.boundary.ground.label.seq<-list()
music.boundary.ground.label.count<-c()
for(i in 1:length(music.boundary.ground.label)){
  cur_label<-music.boundary.ground.label[[i]]
  label_type_count<-0
  
  new_label_seq<-""
  for(j in 1:length(cur_label)){
    
    #if label not exist in new label sequence
    if(length(grep(cur_label[[j]],new_label_seq))==0){
      temp_label<-cur_label[[j]]
      label_type_count<-label_type_count+1
      new_label_seq<-paste(new_label_seq,as.character(label_type_count))
      
      #replace
      for(k in 1:length(cur_label)){
        if(cur_label[[k]]==temp_label)
          cur_label[[k]]<-as.character(label_type_count)
      }
    }
  }
  music.boundary.ground.label.seq[[i]]<-cur_label
  music.boundary.ground.label.count<-c(music.boundary.ground.label.count[],label_type_count)
}

#repair the ending time of ground truth
for(i in 1:length(music.boundary.ground.time)){
  cur_ground_time<-music.boundary.ground.time[[i]]
  cur_ground_time<-rbind(0,cur_ground_time)
  cur_ground_time[nrow(cur_ground_time)]<-music.length[i]
  music.boundary.ground.time[[i]]<-cur_ground_time
}
