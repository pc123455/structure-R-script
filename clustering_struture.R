set.seed(2)

music.feature.plp.pca<-pca_features(music.feature.mean.nomalized.plp)

km.out<-list()
music.boundary.detected.label<-list()
for(i in 1:length(music.feature.plp.pca[[1]])){
  label_count<-music.boundary.ground.label.count[i]
  cur_feature_pca<-music.feature.plp.pca[[1]][[i]]
  k=min(label_count,nrow(cur_feature_pca)-1)
  km.out[[i]]<-kmeans(cur_feature_pca[,1:2],k)
  music.boundary.detected.label[[i]]<-km.out[[i]]$cluster
}

accuracy_list<-evaluating_accuracy(music.boundary.detected.label,music.boundary.time,music.boundary.ground.time,music.boundary.ground.label.seq)

cat(mean(accuracy_list))
#km.out<-kmeans(music.feature.plp.pca[[1]][[1]][,1:2],5,nstart = 20)
#plot(music.feature.plp.pca[[1]][[1]][,1:2],col=(km.out$cluster+1),main="K-Means Clustering Result with K=2",xlab = "",ylab = "",pch=20,cex=2)
