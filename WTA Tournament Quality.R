library(tidyverse)
library(dplyr)
library(readr)
library(knitr)
library(ggplot2)
library(reshape)
library(reshape2)

# Reading files from GitHub
File1 <- "https://raw.githubusercontent.com/ivanxieau/WTA_TennisAbstract/master/wta_matches_2022.csv"
File2 <- "https://raw.githubusercontent.com/ivanxieau/WTA_Statistics/main/2022%20WTA%20Elo.csv"

Matches <- read_csv(File1)
Elo22 <- read_csv(File2)

# Generating new dataframe TQ - Tournament Quality
# Extracting unique tournament names and filtering by WTA250
df <- subset(Matches, select=c("tourney_name", "tourney_level", "winner_name","loser_name","round"))
df <- unique(df)

TQ <- filter(df, tourney_level == "I" , round == "R32")
TQ <- TQ[,-c(2,5)]
TQ <- melt(TQ, id = c("tourney_name"))
TQ <- TQ[,-c(2)]

colnames(TQ)[colnames(TQ) == "value"] <- "Player"

TQ <- merge(x=TQ, y=Elo22, all=TRUE)

print(TQ)