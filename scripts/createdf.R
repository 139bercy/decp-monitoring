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
  summarise_if(is.numeric, cumsum)
date <- stats2$date
stats_cumul <- cbind(date,stats_cumul)

nrows <- nrow(stats2)

nbmarches <- stats2 %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_365J <- stats2[(nrows-365):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_30J <- stats2[(nrows-30):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_10J <- stats2[(nrows-10):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches_3J <- stats2[(nrows-3):nrows,] %>%
  summarise_if(is.numeric, sum, na.rm=T)

nbmarches <- t(rbind(nbmarches, nbmarches_365J, nbmarches_30J, nbmarches_10J, nbmarches_3J))
colnames(nbmarches) <- c("nb", "nb_365J","nb_30J", "nb_10J", "nb_3J")
nbmarches <- as.data.frame(nbmarches)

save(stats2,stats_cumul,nbmarches, file = "scripts/output/stats.Rdata")
