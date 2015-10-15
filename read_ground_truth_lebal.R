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

#replace the label
music.boundary.ground.label.replace<-list()
for(i in 1:length(music.boundary.ground.label)){
  cur_label<-music.boundary.ground.label[[i]]
  for(j in 1:length(cur_label)){
    label_str<-tolower(cur_label[[j]])
    label_str<-tolower(label_str)
    
    #verse
    if(length(grep("mr",label_str))!=0){
      label_str<-"verse"
    }else if(length(grep("verse",label_str))!=0){
      label_str<-"verse"
    }else if(length(grep("ver_se",label_str))!=0){
      label_str<-"verse"
    }
    #instrument
    else if(length(grep("verses",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("verseas",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("versehs",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("versebs",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("solo",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("long_connector",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("short_connector",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("instrumental",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("refrains",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("guitars",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("break",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("bridgebs",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("bridges",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("bridgeas",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("closing",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("close",label_str))!=0){
      label_str<-"instrument"
    }else if(length(grep("interlude",label_str))!=0){
      label_str<-"instrument"
    }
    #refrain
    else if(length(grep("refrain",label_str))!=0){
      label_str<-"refrain"
    }
    #bridge
    else if(length(grep("bridge",label_str))!=0){
      label_str<-"bridge"
    }
    #intro
    else if(length(grep("intro",label_str))!=0){
      label_str<-"intro"
    }
    #outro
    else if(length(grep("outro",label_str))!=0){
      label_str<-"outro"
    }
    #silence
    else if(length(grep("si",label_str))!=0){
      label_str<-"silence"
    }
    #impro
    else if(length(grep("impro",label_str))!=0){
      label_str<-"verse"
    }
    
    cur_label[[j]]<-label_str
  }
  music.boundary.ground.label.replace[[i]]<-cur_label
}



all_label<-""
for(i in 1:length(music.boundary.ground.label.replace)){
  cur_label<-music.boundary.ground.label.replace[[i]]
  for(j in 1:length(cur_label)){
    if(length(grep(cur_label[[j]],all_label))==0){
      all_label<-paste(all_label," ",cur_label[[j]])
    }
  }
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
