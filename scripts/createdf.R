require(dplyr)
require(lubridate)

stats <- read.csv("scripts/output/decp-stats.csv")

nrows <- nrow(stats)
ncols <- ncol(stats)

seq <- seq(as.Date(stats[1,'date']),as.Date(stats[nrows,'date']), by="day")
seq2 <- setdiff(seq,as.Date(stats$date))
df.test <- as.data.frame(array(0, c(length(seq2), ncols)))
colnames(df.test) <- colnames(stats)
df.test$date <- as.Date(seq2, origin = "1970-01-01")

stats2 <- rbind(df.test,stats)
stats2 <- stats2[order(stats2$date),]

stats2[is.na(stats2)] <- 0

stats_cumul <- stats2 %>%
  mutate(aife=cumsum(aife), pes=cumsum(pes), emarchespublics=cumsum(emarchespublics),
         grandlyon=cumsum(grandlyon), marchespublicsinfo=cumsum(marchespublicsinfo))

nrows <- nrow(stats2)

nbmarches <- stats2 %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_100J <- stats2[(nrows-100):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_30J <- stats2[(nrows-30):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_10J <- stats2[(nrows-10):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_3J <- stats2[(nrows-3):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches <- t(rbind(nbmarches, nbmarches_100J, nbmarches_30J, nbmarches_10J, nbmarches_3J))
colnames(nbmarches) <- c("nb", "nb_100J","nb_30J", "nb_10J", "nb_3J")
nbmarches <- as.data.frame(nbmarches)

save(stats2,stats_cumul,nbmarches, file = "scripts/output/stats.Rdata")


# stats2$aife_0 <- sequence(rle(as.character(stats2$aife))$lengths)
# stats2$pes_0 <- sequence(rle(as.character(stats2$pes))$lengths)
# stats2$emarchespublics_0 <- sequence(rle(as.character(stats2$emarchespublics))$lengths)
# stats2$grandlyon_0 <- sequence(rle(as.character(stats2$grandlyon))$lengths)
# stats2$marchespublicsinfo_0 <- sequence(rle(as.character(stats2$marchespublicsinfo))$lengths)
# stats2$annee <- year(stats2$date)
# 
# stats2 %>%
#   group_by(annee) %>%
#   summarise(max_aife=max(aife_0), max_pes=max(pes_0), max_emarchespublics=max(emarchespublics_0),
#             max_grandlyon=max(grandlyon_0), max_marchespublicsinfo=max(marchespublicsinfo_0))

