#return: the music boundary indices 
#input: music length , boundary time and features
get_music_boundary_indices<-function(music_length,boundaries,features){
  indices<-list()
  
  for(i in 1:length(music_length)){
    boundary<-as.vector(unlist(boundaries[[i]]))
    index<-boundary/music_length[[i]]
    #index<-c(index[],1)
    index<-index*ncol(features[[i]])
    index<-round(index)
    indices[[i]]<-index
  }
  return(indices)
}

#return: seperated features of music
#input:music feature,music boundary indices
seperate_feature<-function(features,indices){
  seperated_features<-list()
  for(i in 1:length(features)){
    #current item of feature list
    cur_feature<-features[[i]]
    #current item of indices list
    cur_indices<-indices[[i]]
    
    single_music_feature<-list()
    for(j in 1:(length(cur_indices)-1)){
      single_music_feature[[j]]<-cur_feature[,(cur_indices[j]+1):cur_indices[j+1]]
    }
    seperated_features[[i]]<-single_music_feature
  }
  return(seperated_features)
}

#return: the means matrix of features(a column denotes a variable,a row denotes a sample)
#input: seperated features
means_feature<-function(features){
  means<-list()
  for(i in 1:length(features)){
    cur_feature<-features[[i]]
    #means of the feature of single music
    single_means<-c()
    for(j in 1:length(cur_feature)){
      #cat("i=",i," j= ",j,"\n")
      if(class(cur_feature[[j]])!="matrix"){
        single_means<-c(single_means[],cur_feature[[j]])
      }else{
        single_means<-c(single_means[],rowMeans(cur_feature[[j]]))
      }
    }
    single_means_matix<-matrix(single_means,ncol = length(cur_feature))
    means[[i]]<-t(single_means_matix)
  }
  return(means)
}

#return: nomalized features
#input: music features
nomalizing_feature<-function(features){
  nomalization_feature<-list()
  for(i in 1:length(features)){
    cur_feature<-features[[i]]
    for(j in 1:ncol(cur_feature)){
      cur_col<-cur_feature[,j]
      cat(str(cur_col),"\n")
      mean_feature<-mean(cur_col)
      sd_feature<-sd(cur_col)
      cur_col<-(cur_col-mean_feature)/sd_feature
      cat(str(cur_col),"\n")
      cur_feature[,j]<-cur_col
    }
    nomalization_feature[[i]]<-cur_feature
  }
  return(nomalization_feature)
}

