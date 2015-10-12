set.seed(1)

music.feature.plp.pca<-pca_features(music.feature.mean.nomalized.plp)

km.out<-list()

for(i in 1:length(music.feature.plp.pca[[1]])){
  cur_feature_pca<-music.feature.plp.pca[[1]][[i]]
  km.out[[i]]<-kmeans(cur_feature_pca[,1:2],3,nstart = 20)
}

km.out<-kmeans(music.feature.plp.pca[[1]][[1]][,1:2],5,nstart = 20)
plot(music.feature.plp.pca[[1]][[1]][,1:2],col=(km.out$cluster+1),main="K-Means Clustering Result with K=2",xlab = "",ylab = "",pch=20,cex=2)
