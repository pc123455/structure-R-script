library(rmatio)
write.mat(list(#ground_left=music.ground.feature.mean.nomalized.plp.left[1:182],
               #ground_right=music.ground.feature.mean.nomalized.plp.right[1:182],
               boundary_left=music.feature.mean.nomalized.plp.left[1:182],
               boundary_right=music.feature.mean.nomalized.plp.right[1:182]
               ), filename = file.path(path,"R_datas.mat"), compression = TRUE, version = c("MAT5"))
#unlink(file.path(path,"R_datas.mat"))
