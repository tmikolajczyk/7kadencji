library(dplyr)
library(data.table)


zestaw <- all %>%
  group_by(klub) %>%
  summarise(ile = n()) %>%
  head(30)

partie <- read.csv("partie.csv")
setnames(partie, "partia", "klub")

setkey(as.data.table(zestaw),klub)
setkey(as.data.table(partie),klub)

zestaw <- as.data.frame(merge(zestaw, partie, all.x=TRUE))
zestaw <- zestaw[,c("klub", "kolor", "wikilink")]

#akronimy
zestaw$short <- gsub(pattern="[^A-Z]", replacement = "", zestaw$klub)

#eksport
save(zestaw, file="zestaw.rda")
write.csv(zestaw, file="zestaw.csv", row.names = FALSE)
