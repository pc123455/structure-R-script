#source('F:/struction detection/R Script/structure-R-script/read_music_feature.R')
#source('F:/struction detection/R Script/structure-R-script/feature_operating_functions.R')
#source('F:/struction detection/R Script/structure-R-script/read_ground_truth_lebal.R')
#source('F:/struction detection/R Script/structure-R-script/feature_pca_functions.R')


#music boundary set
##right
music.feature.plp<-music.feature.plp.right

music.boundary.indices<-get_music_boundary_indices(music.length,music.boundary.time,music.feature.plp)

music.feature.seperated.plp<-seperate_feature(music.feature.plp,music.boundary.indices)

music.feature.mean.plp<-means_feature(music.feature.seperated.plp)

music.feature.mean.nomalized.plp.right<-nomalizing_feature(music.feature.mean.plp)

##left
music.feature.plp<-music.feature.plp.left

music.boundary.indices<-get_music_boundary_indices(music.length,music.boundary.time,music.feature.plp)

music.feature.seperated.plp<-seperate_feature(music.feature.plp,music.boundary.indices)

music.feature.mean.plp<-means_feature(music.feature.seperated.plp)

music.feature.mean.nomalized.plp.left<-nomalizing_feature(music.feature.mean.plp)

#music ground truth set
##right
music.feature.plp<-music.feature.plp.right

music.boundary.ground.indices<-get_music_boundary_indices(music.length,music.boundary.ground.time,music.feature.plp)

music.ground.feature.seperated.plp<-seperate_feature(music.feature.plp,music.boundary.ground.indices)

music.ground.feature.mean.plp<-means_feature(music.ground.feature.seperated.plp)

music.ground.feature.mean.nomalized.plp.right<-nomalizing_feature(music.ground.feature.mean.plp)

##left
music.feature.plp<-music.feature.plp.left

music.boundary.ground.indices<-get_music_boundary_indices(music.length,music.boundary.ground.time,music.feature.plp)

music.ground.feature.seperated.plp<-seperate_feature(music.feature.plp,music.boundary.ground.indices)

music.ground.feature.mean.plp<-means_feature(music.ground.feature.seperated.plp)

music.ground.feature.mean.nomalized.plp.left<-nomalizing_feature(music.ground.feature.mean.plp)

