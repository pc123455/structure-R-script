if(FALSE){
pve<-matrix(rep(0,length = 9),ncol = 9)

for(i in 1:length(music.feature.mean.nomalized.plp)){
  cur_feature<-music.feature.mean.nomalized.plp[[i]]
  music.feature.plp.pca<-prcomp(cur_feature,scale = TRUE)
  music.feature.plp.pca.var=music.feature.plp.pca$sdev^2
  music.feature.plp.pca.pve=music.feature.plp.pca.var/sum(music.feature.plp.pca.var)
  pve<-rbind(pve,music.feature.plp.pca.pve)
}

plot(music.feature.plp.pca$x[,1:2])

pve<-colMeans(pve)

plot(pve,xlab = "Principal Component",ylab = "Proportion of Variance Explained",ylim = c(0,1),type = 'b')
plot(cumsum(pve),xlab = "Principal Component",ylab = "Cumulative Proportion of Variance Explained",ylim = c(0,1),type = 'b')

music.feature.plp.pca$x
}

#return: a list of which the first item is the principal component x; the second item is pve
#input: music features
pca_features<-function(features){
  features_principal_comp<-list()
  pve<-matrix(rep(0,length = 9),ncol = 9)
  for(i in 1:length(features)){
    cur_feature<-features[[i]]
    feature.pca<-prcomp(cur_feature,scale = TRUE)
    feature.pca.var=feature.pca$sdev^2
    feature.pca.pve=feature.pca.var/sum(feature.pca.var)
    pve<-rbind(pve,feature.pca.pve)
    features_principal_comp[[i]]<-feature.pca$x
  }
  pve<-colMeans(pve)
  pca.out<-list()
  pca.out[[1]]<-features_principal_comp
  pca.out[[2]]<-pve
  return(pca.out)
}