for(i in 1:length(music.feature.mean.nomalized.plp)){
  cur_feature<-music.feature.mean.nomalized.plp[[i]]
  music.feature.plp.pca<-prcomp(cur_feature,scale = TRUE)
  biplot(music.feature.plp.pca,scale=0)
}