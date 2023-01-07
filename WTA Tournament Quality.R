library(tidyverse)
library(dplyr)
library(readr)
library(knitr)
library(ggplot2)
library(tidyr)
library(reshape)
library(reshape2)
library(stringr)
library(git2r)
library(git2rdata)


# Reading files from GitHub
File1 <- "https://raw.githubusercontent.com/ivanxieau/WTA_Statistics/main/2022_WTA_Matches.csv"
File2 <- "https://raw.githubusercontent.com/ivanxieau/WTA_Statistics/main/2022_WTA_Elo.csv"

Matches <- read_csv(File1)
Elo22 <- read_csv(File2)

# Generating new dataframe TQ - Tournament Quality
# Extracting unique tournament names

df <- subset(Matches, select=c("tourney_name", "tourney_level", "winner_name","loser_name","round"))
df <- unique(df)

# Filtering by tournament level; selecting by R64/R32 as proxy for Entry List
TQ250 <- filter(df, tourney_level == "250" , round == "R32")
TQ500 <- filter(df, tourney_level == "500" , round == "R16" | round == "R32" | round == "R64")
TQ900 <- filter(df, tourney_level == "900" , round == "R32" | round == "R64")

# Removing unnecessary values; cleaning dataframe
TQ250 <- TQ250[,-c(5)]
TQ500 <- TQ500[,-c(5)]
TQ900 <- TQ900[,-c(5)]

TQ250 <- melt(TQ250, id = c("tourney_name", "tourney_level"))
TQ500 <- melt(TQ500, id = c("tourney_name", "tourney_level"))
TQ900 <- melt(TQ900, id = c("tourney_name", "tourney_level"))

TQ250 <- TQ250[,-c(3)]
TQ500 <- TQ500[,-c(3)]
TQ900 <- TQ900[,-c(3)]

colnames(TQ250)[3] = "Player"
colnames(TQ500)[3] = "Player"
colnames(TQ900)[3] = "Player"

# Remove player duplicates from 500 and 900 tournaments
TQ500 <- unique(TQ500)
TQ900 <- unique(TQ900)

# Adding 2022 Elo ranking points to dataframe - could be cleaner
TQ250 <- left_join(TQ250, Elo22, by = character())
TQ500 <- left_join(TQ500, Elo22, by = character())
TQ900 <- left_join(TQ900, Elo22, by = character())

# Removing fake values created by Full Join; clean dataframe
TQ250$Match <- str_equal(TQ250$Player.x, TQ250$Player.y, ignore_case=TRUE)
TQ250 <- subset(TQ250,Match=="TRUE")

TQ250 <- TQ250[,-c(4,6,7,8,9)]
colnames(TQ250)[3] = "Player"

# Repeat for WTA500
TQ500$Match <- str_equal(TQ500$Player.x, TQ500$Player.y, ignore_case=TRUE)
TQ500 <- subset(TQ500,Match=="TRUE")
TQ500 <- TQ500[,-c(4,6,7,8,9)]
colnames(TQ500)[3] = "Player"

# Repeat for WTA900
TQ900$Match <- str_equal(TQ900$Player.x, TQ900$Player.y, ignore_case=TRUE)
TQ900 <- subset(TQ900,Match=="TRUE")
TQ900 <- TQ900[,-c(4,6,7,8,9)]
colnames(TQ900)[3] = "Player"

print(TQ250)

# Average Elo of competing players 
TQ250M <- aggregate(Elo~tourney_name + tourney_level,TQ250,mean)
TQ250M <- TQ250M[order(-TQ250M$Elo),]

TQ500M <- aggregate(Elo~tourney_name + tourney_level,TQ500,mean)
TQ500M <- TQ500M[order(-TQ500M$Elo),]

TQ900M <- aggregate(Elo~tourney_name + tourney_level,TQ900,mean)
TQ900M <- TQ900M[order(-TQ900M$Elo),]

# Creating combined dataframe

TQ_WTA <- rbind(TQ250M, TQ500M, TQ900M)
TQ_WTA <- TQ_WTA[order(TQ_WTA$tourney_level),]

# Write to desktop
write.csv(TQ250M,file="C:\\Users\\ivanx\\Documents\\GitHub\\WTA_Statistics\\22_250_TQ.csv", row.names=FALSE)
write.csv(TQ500M,file="C:\\Users\\ivanx\\Documents\\GitHub\\WTA_Statistics\\22_500_TQ.csv", row.names=FALSE)
write.csv(TQ900M,file="C:\\Users\\ivanx\\Documents\\GitHub\\WTA_Statistics\\22_900_TQ.csv", row.names=FALSE)
write.csv(TQ_WTA,file="C:\\Users\\ivanx\\Documents\\GitHub\\WTA_Statistics\\22_WTA.csv", row.names=FALSE)