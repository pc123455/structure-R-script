music.boundary.indices<-get_music_boundary_indices(music.length,music.boundary.time,music.feature.plp)

music.feature.seperated.plp<-seperate_feature(music.feature.plp,music.boundary.indices)

music.feature.mean.plp<-means_feature(music.feature.seperated.plp)
