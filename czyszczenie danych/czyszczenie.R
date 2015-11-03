library(stringr)
library(dplyr)
library(sqldf)

kluby <- unique(all$klub)

#porządkujemy
kluby <- gsub("Koło Poselskie ", "", kluby)
kluby <- gsub("Klub Parlamentarny ", "", kluby) 
kluby <- gsub("Klub Poselski ", "", kluby) 
kluby <- gsub("Koło Parlamentarne ", "", kluby) 
kluby <- gsub(" Koło Poselskie", "", kluby) 
kluby <- gsub(" Klub Parlamentarny", "", kluby) 
kluby <- gsub(" Koło Parlamentarne", "", kluby) 
kluby <- gsub("Unii", "Unia", kluby) 
kluby <- gsub("Platforma Obywatelska RP", "Platforma Obywatelska", kluby) 
kluby <- gsub("Akcji Polskiej", "Akcja Polska", kluby) 
kluby <- gsub("Akcji Wyborczej", "Akcja Wyborcza", kluby) 
kluby <- gsub("Bezpartyjnego Bloku", "Bezpartyjny Blok", kluby) 
kluby <- gsub("Konfederacji", "Konfederacja", kluby) 
kluby <- gsub("Niezależny Samorządny Związek Zawodowy Solidarność", "NSZZ Solidarność", kluby) 
kluby <- gsub("Polskiego Stronnictwa Ludowego", "Polskie Stronnictwo Ludowe", kluby) 
kluby <- gsub("Polskiej Partii Socjalistycznej", "Polska Partia Socjalistyczna", kluby) 
kluby <- gsub("Porozumienia", "Porozumienie", kluby) 
kluby <- gsub("Samoobrona Rzeczypospolitej Polskiej", "Samoobrona Rzeczpospolitej Polskiej", kluby) 
kluby <- gsub("Samoobrony Rzeczpospolitej Polskiej", "Samoobrona Rzeczpospolitej Polskiej", kluby) 
kluby <- gsub("Stronnictwa Gospodarczego", "Stronnictwo Gospodarcze", kluby) 
kluby <- gsub("Stronnictwa Konserwatywno-Ludowego", "Stronnictwo Konserwatywno-Ludowe", kluby) 
kluby <- gsub("Ludowego Sojuszu Programowego", "Ludowe", kluby) 
kluby <- gsub("Porozumienie Polskiego", "Porozumienie Polskie", kluby)
kluby <- gsub("Socjaldemokracji Polskiej", "Socjaldemokracja Polska", kluby) 
kluby <- gsub("Sojuszu", "Sojusz", kluby) 
kluby <- gsub("Ruchu", "Ruch", kluby) 
kluby <- gsub("Federacyjny na rzecz Akcja Wyborcza Solidarność", "Federacyjny Klub Parlamentarny na rzecz AWS", kluby) 
kluby <- gsub("Partii", "Partia", kluby) 
kluby <- gsub("Zjednoczenia Chrześcijańsko-Narodowego", "Zjednoczenie Chrześcijańsko-Narodowe", kluby) 
kluby <- gsub("Narodowego", "Narodowy", kluby) 
kluby <- gsub("KWW ", "", kluby) 
kluby <- sapply(kluby, function(x) gsub("\"", "", x))

# z powrotem do raki i sortujemy
kluby <- as.data.frame(unique(kluby))
colnames(kluby) <- c("kluby")
kluby <- kluby %>%
  arrange(kluby)

#akronimy
kluby$short <- gsub(pattern="[^A-Z]", replacement = "", kluby$partia)

#łączymy z zestawieniem Piotra
partie <- read.csv("partie.csv")
colnames(partie) <- c("kluby","kolor","wikilink","kadencja_pierwsza","kadencja_ostatnia")
partie <- sqldf("select * from kluby left join partie using (kluby)")

write.csv(partie, file="partie_all.csv")
