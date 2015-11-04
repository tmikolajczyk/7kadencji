library(stringr)
library(dplyr)
library(sqldf)

kluby <- unique(all$klub)
kluby_old_new <- as.data.frame(kluby)
kluby_old_new$new <- kluby_old_new$new
colnames(kluby_old_new) <- c("klub", "old")

#porządkujemy
kluby_old_new$new <- gsub("Koło Poselskie ", "", kluby_old_new$new)
kluby_old_new$new <- gsub("Klub Parlamentarny ", "", kluby_old_new$new) 
kluby_old_new$new <- gsub("Klub Poselski ", "", kluby_old_new$new) 
kluby_old_new$new <- gsub("Koło Parlamentarne ", "", kluby_old_new$new) 
kluby_old_new$new <- gsub(" Koło Poselskie", "", kluby_old_new$new) 
kluby_old_new$new <- gsub(" Klub Parlamentarny", "", kluby_old_new$new) 
kluby_old_new$new <- gsub(" Koło Parlamentarne", "", kluby_old_new$new) 
kluby_old_new$new <- gsub("Unii", "Unia", kluby_old_new$new) 
kluby_old_new$new <- gsub("Platforma Obywatelska RP", "Platforma Obywatelska", kluby_old_new$new) 
kluby_old_new$new <- gsub("Akcji Polskiej", "Akcja Polska", kluby_old_new$new) 
kluby_old_new$new <- gsub("Akcji Wyborczej", "Akcja Wyborcza", kluby_old_new$new) 
kluby_old_new$new <- gsub("Bezpartyjnego Bloku", "Bezpartyjny Blok", kluby_old_new$new) 
kluby_old_new$new <- gsub("Konfederacji", "Konfederacja", kluby_old_new$new) 
kluby_old_new$new <- gsub("Niezależny Samorządny Związek Zawodowy Solidarność", "NSZZ Solidarność", kluby_old_new$new) 
kluby_old_new$new <- gsub("Polskiego Stronnictwa Ludowego", "Polskie Stronnictwo Ludowe", kluby_old_new$new) 
kluby_old_new$new <- gsub("Polskiej Partii Socjalistycznej", "Polska Partia Socjalistyczna", kluby_old_new$new) 
kluby_old_new$new <- gsub("Porozumienia", "Porozumienie", kluby_old_new$new) 
kluby_old_new$new <- gsub("Samoobrona Rzeczypospolitej Polskiej", "Samoobrona Rzeczpospolitej Polskiej", kluby_old_new$new) 
kluby_old_new$new <- gsub("Samoobrony Rzeczpospolitej Polskiej", "Samoobrona Rzeczpospolitej Polskiej", kluby_old_new$new) 
kluby_old_new$new <- gsub("Stronnictwa Gospodarczego", "Stronnictwo Gospodarcze", kluby_old_new$new) 
kluby_old_new$new <- gsub("Stronnictwa Konserwatywno-Ludowego", "Stronnictwo Konserwatywno-Ludowe", kluby_old_new$new) 
kluby_old_new$new <- gsub("Ludowego Sojuszu Programowego", "Ludowe", kluby_old_new$new) 
kluby_old_new$new <- gsub("Porozumienie Polskiego", "Porozumienie Polskie", kluby_old_new$new)
kluby_old_new$new <- gsub("Socjaldemokracji Polskiej", "Socjaldemokracja Polska", kluby_old_new$new) 
kluby_old_new$new <- gsub("Sojuszu", "Sojusz", kluby_old_new$new) 
kluby_old_new$new <- gsub("Ruchu", "Ruch", kluby_old_new$new) 
kluby_old_new$new <- gsub("Federacyjny na rzecz Akcja Wyborcza Solidarność", "Federacyjny Klub Parlamentarny na rzecz AWS", kluby_old_new$new) 
kluby_old_new$new <- gsub("Partii", "Partia", kluby_old_new$new) 
kluby_old_new$new <- gsub("Zjednoczenia Chrześcijańsko-Narodowego", "Zjednoczenie Chrześcijańsko-Narodowe", kluby_old_new$new) 
kluby_old_new$new <- gsub("Narodowego", "Narodowy", kluby_old_new$new) 
kluby_old_new$new <- gsub("KWW ", "", kluby_old_new$new) 
kluby_old_new$new <- sapply(kluby_old_new$new, function(x) gsub("\"", "", x))

# z powrotem do ramki i sortujemy
kluby <- as.data.frame(unique(kluby_old_new$new))
colnames(kluby) <- c("kluby")
kluby <- kluby %>%
  arrange(kluby)

#akronimy
kluby$short <- gsub(pattern="[^A-Z]", replacement = "", kluby$kluby)

#łączymy z zestawieniem Piotra
partie <- read.csv("partie.csv")
colnames(partie) <- c("kluby","kolor","wikilink","kadencja_pierwsza","kadencja_ostatnia")
partie <- sqldf("select * from kluby left join partie using (kluby)")

write.csv(partie, file="partie_all.csv")
write.csv(kluby_old_new, file="slownik_klubow.csv")
