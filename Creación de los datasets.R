#Elijo el directorio y los paquetes
setwd("~/Downloads/Trolls")
if (!require(tidyr)) install.packages("tidyr")
if (!require(purrr)) install.packages("purrr")
if (!require(readr)) install.packages("readr")

#Limpio el ambiente global
rm(list = ls())

#Creo el dataset de tweets
data_path <- "tweets"
files <- dir(data_path, pattern = "*.csv")
data <- data_frame(filename = files) %>% 
  # create a data frame # holding the file names 
  mutate(file_contents = map(filename, 
                             # read files into 
                             ~ read_csv(file.path(data_path, .))) 
         # a new data column 
  )            
tweets <- unnest(data)
rm(data)
write.csv(tweets, "tweets.csv", row.names = F)

#Creo el dataset de contributors
data_path <- "contributors"
files <- dir(data_path, pattern = "*.csv")
data <- data_frame(filename = files) %>% 
  # create a data frame # holding the file names 
  mutate(file_contents = map(filename, 
                             # read files into 
                             ~ read_csv(file.path(data_path, .))) 
         # a new data column 
  )            
contributors <- unnest(data)
rm(data)
write.csv(contributors, "contributors.csv", row.names = F )
