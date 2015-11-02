library(dplyr)
library(tidyr)
library(rvest)
library(XML)
library(sqldf)


#adres strony, pobranie listy posłów oraz klubów, tworzenie ramki danych
url <- "https://pl.wikipedia.org/wiki/Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_VII_kadencji"
lista <- html_text(html_nodes(read_html(url), ".wikitable li a , ul+ .wikitable th"))
kluby <- read_html(url) %>% html_nodes("ul+ .wikitable th") %>% html_text
df <- data.frame(kadencja="7",etap="end",lista, klub="", stringsAsFactors = FALSE)

#przypisanie klubu do posła na podstawie ostatniego wystąpienie nazwy klubu
ostatni_klub = ""
for(i in 1:length(lista)){
  if (is.element(df[i,'lista'], kluby)){
    df[i, 'klub'] <- ""
    ostatni_klub <- df[i,'lista']
  } else {
    df[i, 'klub'] <- ostatni_klub
  }
}

#tylko wiersze z poseł+klub
df <- df %>%
  filter(klub !="") 

#przerzucenie wartości przypisu do kolumny 'klub'
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

#eksport do zewnętrznego pliku -> tam edycja -> import danych
#write.csv(przypisy, "przypisy_7K.csv")
przypisy <- read.csv("przypisy_7K.csv", sep=",")

#podmiana wartości przypisów na klub po zmianie
df <- sqldf("select * from df left join przypisy using (lista)")

#przerzucenie nazwy klubu do kolumny 'klub'
for(k in 1:length(df$lista)){
  if (!is.na(df$poprzedni[k])){
    df$klub[k] <- df$poprzedni[k]
    }
}

#usuwamy kolumnę "poprzedni'
df <- df %>%
  select(kadencja, etap, lista, klub)

#usuwamy rekordy z przypisami, które nie informują o zmianie klubu
df <- df %>%
  filter(!grepl("^\\[.\\]|\\[..\\]$", klub))

#podmiana przypisu na własciwe nazwisko na liście
for(l in 1:length(df$lista)){
  if (grepl("^\\[.\\]|\\[..\\]$", df$lista[l])){
    df[l, 'lista'] <- df[l-1, 'lista']
  }
}

#podwojenie wierszy dla posłów którzy nie zmieniali klubu
#wyfiltorowanie posłów którzy nie zmieniali klubu
df.new <- df %>%
  group_by(lista) %>%
  filter(n() == 1) 

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

df_7K <- df %>%
  arrange(lista, desc(etap))

rm(df.new)