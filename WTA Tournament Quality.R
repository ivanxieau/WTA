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
File1 <- "https://raw.githubusercontent.com/ivanxieau/WTA_TennisAbstract/master/wta_matches_2022.csv"
File2 <- "https://raw.githubusercontent.com/ivanxieau/WTA_Statistics/main/2022_WTA_Elo.csv"

Matches <- read_csv(File1)
Elo22 <- read_csv(File2)

# Generating new dataframe TQ - Tournament Quality
# Extracting unique tournament names

df <- subset(Matches, select=c("tourney_name", "tourney_level", "winner_name","loser_name","round"))
df <- unique(df)

# Filtering by WTA250; selecting by R32 as proxy for Entry List
TQ <- filter(df, tourney_level == "I" , round == "R32")

# Removing unnecessary values
TQ <- TQ[,-c(2,5)]
TQ <- melt(TQ, id = c("tourney_name"))
TQ <- TQ[,-c(2)]
colnames(TQ)[2] = "Player"

# Adding 2022 Elo ranking points to dataframe - could be cleaner
TQ <- left_join(TQ, Elo22, by = character())

# Removing fake values created by Full Join; clean dataframe
TQ$Match <- str_equal(TQ$Player.x, TQ$Player.y, ignore_case=TRUE)
TQ <- subset(TQ,Match=="TRUE")
TQ <- TQ[,-c(3,5,6,7,8)]
colnames(TQ)[2] = "Player"

# Average Elo of competing players 
TQSum <- aggregate(Elo~tourney_name,TQ,mean)
TQSum <- TQSum[order(-TQSum$Elo),]
print(TQSum)

# Write to desktop
write.csv(TQSum,file="C:\\Users\\ivanx\\Documents\\GitHub\\WTA_Statistics\\22_250_TQ.csv", row.names=FALSE)
