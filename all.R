library(stringr)
library(data.table)


#połączenie zestawień dla 8 kadencji
all <- rbind(df_1K,df_2K,df_3K,df_4K,df_5K,df_6K,df_7K,df_8K)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#czyszczenie nazewnictwa klubów 
kluby <- unique(all$klub)
kluby_old_new <- as.data.frame(kluby)
kluby_old_new$new <- kluby_old_new$kluby
colnames(kluby_old_new) <- c("new", "klub")

#porządkujemy
kluby_old_new$new <- gsub("Koło Poselskie ", "", kluby_old_new$new)
kluby_old_new$new <- gsub("Parlamentarne Koło Mniejszości Niemieckiej", "Mniejszość Niemiecka", kluby_old_new$new)
kluby_old_new$new <- gsub("Koło Mniejszości Niemieckiej", "Mniejszość Niemiecka", kluby_old_new$new)
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
kluby_old_new$new <- gsub("Sojusz Lewicy Demokratycznej – Unia Pracy", "Sojusz Lewicy Demokratycznej", kluby_old_new$new) 
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
kluby_old_new$new <- gsub("Federacyjny na rzecz Akcja Wyborcza Solidarność", "Akcja Wyborcza Solidarność", kluby_old_new$new) 
kluby_old_new$new <- gsub("Partii", "Partia", kluby_old_new$new) 
kluby_old_new$new <- gsub("Zjednoczenia Chrześcijańsko-Narodowego", "Zjednoczenie Chrześcijańsko-Narodowe", kluby_old_new$new) 
kluby_old_new$new <- gsub("Narodowego", "Narodowy", kluby_old_new$new) 
kluby_old_new$new <- gsub("KWW ", "", kluby_old_new$new) 
kluby_old_new$new <- gsub("Porozumienie Obywatelskie Centrum", "Porozumienie Centrum", kluby_old_new$new) 
kluby_old_new$new <- sapply(kluby_old_new$new, function(x) gsub("\"", "", x))

#usunięcie pozostałych przypisów
kluby_old_new$new <- str_replace_all(kluby_old_new$new, "\\[.\\]|\\[..\\]", "")

# czyszczenie nazw w głównej ramce danych (all)
setkey(as.data.table(all),klub)
setkey(as.data.table(kluby_old_new),klub)
all <- as.data.frame(merge(all, kluby_old_new, all.x=TRUE))

#wybór kolumn i ich nazwy
vars <- names(all) %in% c("klub") 
all <- all[!vars]
colnames(all) <- c("kadencja", "etap", "osoba", "klub")

#eksport danych do plików
save(all, file="all.rda")
write.csv(all, file="all.csv")
write.csv(all, file="all_clear.csv", fileEncoding='utf8')
