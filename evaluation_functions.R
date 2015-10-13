evaluating_accuracy<-function(detected_label_list,detected_time_list,ground_time_list,ground_label_list){
  accuracy_list<-c()
  proportion<-100
  for(i in 1:length(detected_label_list)){
    cur_detected_label<-detected_label_list[[i]]
    cur_detected_time<-detected_time_list[[i]]
    cur_ground_time<-ground_time_list[[i]]
    cur_ground_label<-ground_label_list[[i]]
    
    #create sample array
    cur_detected_sample_array<-rep(0,round(cur_detected_time[length(cur_detected_time)]*proportion))
    cur_ground_sample_array<-rep(0,round(cur_detected_time[length(cur_detected_time)]*proportion))

    #initalizing detected array
    for(j in 1:(length(cur_detected_time)-1)){
      #cat("i=",i,",j=",j,"\n")
      #cat(cur_detected_sample_array[(round(cur_detected_time[j+1]*proportion))],"\n")
      begin<-round(cur_detected_time[j]*proportion)+1
      end<-round(cur_detected_time[j+1]*proportion)
      cur_detected_sample_array[begin:end]<-cur_detected_label[j]
    }
    
    #initalizing ground array
    for(j in 1:(length(cur_ground_time)-1)){
      begin<-round(cur_ground_time[j]*proportion)+1
      end<-round(cur_ground_time[j+1]*proportion)
      cur_ground_sample_array[begin:end]<-as.numeric(cur_ground_label[j])
    }
    #cat(class(cur_ground_sample_array),"\n")
    #compare two arrays
    count<-0
    for(j in 1:min(length(cur_detected_sample_array),length(cur_ground_sample_array))){
      if(cur_detected_sample_array[j]==cur_ground_sample_array[j]){
        count<-count+1
      }
    }
    
    accuracy<-count/min(length(cur_detected_sample_array),length(cur_ground_sample_array))
    cat(accuracy*100,"%\n")
    accuracy_list<-c(accuracy_list[],accuracy)
  }
  return(accuracy_list)
}