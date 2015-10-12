#source('F:/struction detection/R Script/structure-R-script/read_music_feature.R')
#source('F:/struction detection/R Script/structure-R-script/feature_operating_functions.R')


music.boundary.indices<-get_music_boundary_indices(music.length,music.boundary.time,music.feature.plp)

music.feature.seperated.plp<-seperate_feature(music.feature.plp,music.boundary.indices)

music.feature.mean.plp<-means_feature(music.feature.seperated.plp)

music.feature.mean.nomalized.plp<-nomalizing_feature(music.feature.mean.plp)

