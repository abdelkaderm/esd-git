HadCRUT4 <- function(url="http://www.metoffice.gov.uk/hadobs/hadcrut4/data/current/time_series/HadCRUT.4.2.0.0.monthly_ns_avg.txt",plot=FALSE) {

  X <- read.table(url)
  year <- as.numeric(substr(X$V1,1,4))
  month <-  as.numeric(substr(X$V1,6,7))
  T2m <- zoo(X$V2,as.Date(paste(year,month,"15",sep="-")))
  if (plot) plot(T2m)
  T2m
}
