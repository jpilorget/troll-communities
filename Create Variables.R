#Elijo el directorio y los paquetes
setwd("~/Downloads/Trolls")
if (!require(lubridate)) install.packages("lubridate")
if (!require(dplyr)) install.packages("dplyr")

#Limpio el ambiente global
rm(list = ls())

#Cargo los datasets y creo un dataset en común
tweets <- read.csv("tweets.csv", encoding = "latin1")
contributors <- read.csv("contributors.csv", encoding = "latin1")
names(tweets) <- tolower(names(tweets))
tweets$filename <- gsub("\\_.*","",tweets$filename)
contributors$filename <- gsub("\\_.*","",contributors$filename)

dataset <- merge(tweets, contributors, by = c("screen_name", "user_url", "filename"))
rm(list = c("tweets", "contributors"))

#Modifico el tipo de codificación y los acentos de los datos
dataset[,c(5,32,34)] <- apply(dataset[,c(5,32,34)], 2, function(x) chartr("áéíóú", "aeiou", x))

#Creo variables de fecha y hora
dataset$time <- as.POSIXct(strptime(dataset$time, "%Y-%m-%d %H"))
dataset$hour <- hour(dataset$time)
dataset$year_creation <- year(dataset$profile_created_at)
dataset$profile_created_at <- as.POSIXct(strptime(dataset$profile_created_at, "%Y-%m-%d %H"))
dataset$created_since <- -1*round(as.numeric(Sys.time() - dataset$profile_created_at))

#Creo cocientes para analizar
dataset$likes2foll <- round(dataset$profile_likes_count / dataset$profile_following_count)
dataset$likes2ant <- round(dataset$profile_likes_count / (-1*dataset$created_since))
dataset$tweets2ant <- round(dataset$profile_tweet_count / (-1*dataset$created_since))
dataset$likes2tweets <- round(dataset$profile_likes_count / dataset$profile_tweet_count)

#Agrego variables de "No vuelven más"
novuelvenmas <- read.csv("novuelvenmas.csv")
participaciones <- as.data.frame(sort(table(novuelvenmas$author),decreasing = T))
colnames(participaciones) <- c("screen_name","nvm_cant")
dataset <- merge(dataset,participaciones, by = "screen_name", all.x = T)


#Creo un dataset con toda la información (hasta este momento)
write.csv(dataset, "dataset.csv", row.names = F)
