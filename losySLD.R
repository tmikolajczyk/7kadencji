# 
# Co się działo z SLD
load("/Users/pbiecek/GitHub/7kadencji/all.rda")

head(all)

all <- as.data.frame(all)

all$SLD <- grepl(all$klub, pattern = "Sojusz.? Lewicy Demokratycznej") | grepl(all$klub, pattern = "SLD")

all$etap <- factor(all$etap, levels = c("start","end"), labels = c("", "end"))
  
tmp <- 100*prop.table(table(all$SLD, paste(all$kadencja, all$etap)),2)[2,]
df <- data.frame(SLD = tmp, czas = names(tmp))

library(ggplot2)

pl <- ggplot(df, aes(x=czas, y=SLD)) +
  geom_bar(stat="identity", fill="red3") +
  theme_bw() + xlab("") + ylab("% SLD w Sejmie")

ggsave(pl, file="SLDwSejmie.pdf")

