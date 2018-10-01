library(tidyverse)
library(rvest)
library(XML)
library(sqldf)
library(purrr)
library(stringi)

# iterations for futnotes decoding
ids      <- c(letters, paste0("a", letters), paste0("b", letters))

url      <- "https://pl.wikipedia.org/wiki/Posłowie_na_Sejm_Rzeczypospolitej_Polskiej_I_kadencji_(1991–1993)"
url      <- "https://pl.wikipedia.org/wiki/Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_II_kadencji_(1993%E2%80%931997)"
url      <- "https://pl.wikipedia.org/wiki/Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_III_kadencji_(1997%E2%80%932001)"
url      <- "https://pl.wikipedia.org/wiki/Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_IV_kadencji_(2001%E2%80%932005)"

clubs    <- read_html(url) %>% html_nodes("p+ .wikitable th , ul+ .wikitable th") %>% html_text
deputies <- read_html(url) %>% html_nodes(".wikitable li a , p+ .wikitable th") %>% html_text
notes    <- read_html(url) %>% html_nodes(".mw-references-columns .reference-text") %>% html_text
notes    <- tibble(notes, id = paste0("[", ids[1:length(notes)], "]"))


data     <- tibble(deputy = deputies, club = "") %>% 
  mutate(club = ifelse(deputy %in% clubs, paste0(deputy), "")) %>% 
  left_join(notes, by = c("deputy" = "id")) %>% 
  mutate(deputy = ifelse(grepl("^\\[", deputy), lag(deputy), deputy))


diffs    <- diff(c(which((data$club == "") == F), length(data$deputy) + 1))
clubs    <- map2(clubs, diffs, ~rep(.x, times = .y)) %>% unlist()
data     <- data %>% 
  mutate(club = clubs) %>% 
  filter(!deputy == club)

duplicat <- data %>% select(deputy) %>% count(deputy) %>% filter(n > 1) %>% .$deputy

if(length(duplicat) > 0) {
  data <- data %>% 
    mutate(deputy = ifelse(deputy %in% duplicat, 
                           paste0(deputy, " ", toupper(abbreviate(stri_trans_general(club, "ASCII-Latin")))), 
                           deputy))
}


# zmiana nazwiska dla Tadeusz Kowalczyk (dwie osoby o tym samym imieniu i nazwisku)
df$lista[df$lista == "Tadeusz Kowalczyk" & df$klub == "Klub Parlamentarny Konwencja Polska"] <-
  "Tadeusz Kowalczyk (ur. 1933)"

# tylko wiersze z posel + klub
df <- df %>% filter(klub !="") 

# przerzucenie wartosci przypisu do kolumny 'klub'
for(j in 1:length(df$lista)){
  if (grepl("^\\[.\\]|\\[..\\]$", df$lista[j])) {
    df$klub[j] <- df$lista[j]
    df$etap[j] <- "start"
  }
}

#generowanie zestawienia z wierszami zawierającymi przypisy
#przypisy <- df %>%
#  filter(grepl("^\\[.\\]|\\[..\\]$", lista)) %>%
#  group_by(lista) %>%
#  summarise(poprzedni = n()) 

#przypisy[,2] =""

# eksport do zewnetrznego pliku -> tam edycja -> import danych
# write.csv(przypisy, "przypisy_1K.csv")
przypisy <- read.csv("pobieranie danych/przypisy_1K.csv", sep = ",")

# podmiana wartosci przypisow na klub po zmianie
df <- sqldf("select * from df left join przypisy using (lista)")
df %>% 
  left_join(przypisy)

# przerzucenie nazwy klubu do kolumny 'klub'
for(k in 1:length(df$lista)){
  if (!is.na(df$poprzedni[k])){
    df$klub[k] <- df$poprzedni[k]
  }
}

# usuwamy kolumn "poprzedni'
df <- df %>% select(kadencja, etap, lista, klub)

#usuwamy rekordy z przypisami, które nie informują o zmianie klubu
df <- df %>% filter(!grepl("^\\[.\\]|\\[..\\]$", klub))

# podmiana przypisu na wlasciwe nazwisko na liście
for(l in 1:length(df$lista)){
  if (grepl("^\\[.\\]|\\[..\\]$", df$lista[l])){
    df[l, 'lista'] <- df[l-1, 'lista']
  }
}

# podwojenie wierszy dla poslow ktorzy nie zmieniali klubu
# wyfiltorowanie poslow ktorzy nie zmieniali klubu
df.new <- df %>% group_by(lista) %>% filter(n() == 1) 

#zdublowanie wierszy
df.new <- rbind(df.new,df.new)

#posortowanie wierszy po osobach
df.new <- df.new %>%
  ungroup %>%
  arrange(lista)

#nadanie flagi początkowej i końcowej afiliacji
df.new$etap <- c("start", "end")

#scalenie listy posłów
df <- rbind(df.new,df %>%
              group_by(lista) %>%
              filter(n() > 1)) 

df_1K <- df %>%
  arrange(lista, desc(etap))

rm(df.new)

