library(stringr)


#połączenie zestawień dla 7 kadencji
all <- rbind(df_1K,df_2K,df_3K,df_4K,df_5K,df_6K,df_7K)

#nazwy kolumn
colnames(all) <- c("kadencja", "etap", "osoba", "klub")

#usunięcie pozotsałych przypisów
all$klub <- str_replace_all(all$klub, "\\[.\\]|\\[..\\]", "")

#eksport danych do plików
save(all, file="all.rda")
write.csv(all, file="all.csv", sep=";")
