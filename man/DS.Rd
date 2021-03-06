\name{DS}
\alias{DS}
\alias{DS.default}
\alias{DS.station}
\alias{DS.eof}
\alias{DS.comb}
\alias{DS.field}
\alias{DS.t2m.month.field}
\alias{DS.t2m.season.field}
\alias{DS.t2m.annual.field}
\alias{DS.precip.season.field}
\alias{DS.freq}
\alias{DS.spell}
\alias{DS.pca}
\alias{biasfix}
\alias{sametimescale}
\title{Downscale}
\description{Identifies statistical relationships between large-scale
  spatial climate patterns and local climate variations for monthly and
  daily data series.

  The function calibrates a linear regression model using
  step-wise screening and common EOFs (\code{\link{EOF}}) as basis
  functions. It then valuates the statistical relationship and predicts
  the local climate parameter from predictor fields.

  The function is a S3 method that Works with ordinary EOFs,
  common EOFs (\code{\link{combine}}) and mixed-common EOFs.  DS can
  downscale results for a single station record as well as a set of
  stations. There are two ways to apply the downscaling to several
  stations; either by looping through each station and caryying out the
  DS individually or by using \code{\link{PCA}} to describe the
  characteristics of the whole set. Using PCA will preserve the spatial
  covariance seen in the past. It is also possible to compute the PCA
  prior to carrying out the DS, and use the method
  \code{DS.pca}. \code{DS.pca} differs from the more generic \code{DS}
  by (default) invoking different regression modules (\code{link{MVR}}
  or \code{\link{CCA}}).
  
  The rationale for using mixed-common EOFs is that the coupled
  structures described by the mixed-field EOFs may have a more physical
  meaning than EOFs of single fields [Benestad et al. (2002),
  "Empirically downscaled temperature scenarios for Svalbard",
  \emph{Atm. Sci. Lett.}, doi.10.1006/asle.2002.0051].

  The function \code{DS()} is a generic routine which in principle works for
  when there is any real statistical relationship between the predictor
  and predictand. The predictand is therefore not limited to a climate
  variable, but may also be any quantity affected by the regional
  climate. \emph{It is important to stress that the downscaling model
  must reflect a well-understood (physical) relationship.} 

  The routine uses a step-wise regression (step) using the leading
  EOFs. The calibration is by default carried out on de-trended data
  [ref: Benestad (2001), "The cause of warming over Norway in the
  ECHAM4/OPYC3 GHG integration", \emph{Int. J. Clim.}, 15 March,
  \bold{vol 21}, p.371-387.].

  The function \code{biasfix} provides a type of 'bias correction' based
  on the method \code{\link{diagnose}} which estimates the difference in
  the mean for the PCs of the calibration data and GCMs over a common
  period in addition to the ratio of standard deviations and lag-one
  autocorrelation. This 'bias correction' is described in Imbert and
  Benestad (2005), \emph{Theor. Appl. Clim.} \url{http://dx.doi.org/10.1007/s00704-005-0133-4}.
}
\usage{
DS(y,X,verbose=TRUE,plot=FALSE,...)
DS.default(y,X,mon=NULL,
           method="lm",swsm="step",
           rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
           verbose=FALSE,...)
DS.station(y,X,biascorrect=FALSE,mon=NULL,
           method="lm",swsm="step",
           rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
           verbose=FALSE,pca=TRUE,neofs=20,...)
DS.eof(X,y,mon=NULL,
       method="lm",swsm="step",
       rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
       verbose=FALSE,pca=TRUE,npca=20,...)
DS.comb(X,y,biascorrect=FALSE,mon=NULL,
        method="lm",swsm="step",
        rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
        verbose=FALSE,...) 
DS.field(X,y,biascorrect=FALSE,mon=NULL,
         method="lm",swsm="step",
         rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
         verbose=FALSE,...) 
DS.t2m.month.field(y,X,biascorrect=FALSE,mon=NULL,
                   method="lm",swsm="step",
                   rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
                   verbose=FALSE,station=TRUE)
DS.t2m.season.field(y,X,biascorrect=FALSE,
                    method="lm",swsm="step",
                    rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
                    verbose=FALSE,station=TRUE)
DS.t2m.annual.field(y,X,biascorrect=FALSE,
                    method="lm",swsm="step",
                    rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
                    verbose=FALSE,station=TRUE)
DS.precip.season.field(y,X,biascorrect=FALSE,
                      method="lm",swsm="step",
                      rmtrend=TRUE,eofs=1:7,area.mean.expl=FALSE,
                      verbose=FALSE,...)
DS.freq(y,X,threshold=1,biascorrect=FALSE,method="glm",
family="gaussian",swsm="step",
        rmtrend=TRUE,eofs=1:7,verbose=FALSE,...)
DS.spell(y,X,threshold=1,biascorrect=FALSE,method="glm",
family="gaussian",swsm="step",
         rmtrend=TRUE,eofs=1:7,verbose=FALSE,...)
DS.pca(y,X,biascorrect=FALSE,mon=NULL,
       method="MVR",swsm=NULL,rmtrend=TRUE,...) 
predict.ds.mon(x,...) 
sametimescale(y,X,FUN=mean)
biasfix(x)

}
\arguments{
\item{y}{The predictand - the station series representing local climate parameter}
\item{X}{The predictor - an \code{\link{EOF}} object representing the large-scale situation.}
\item{mon}{An integer or a vector of integers. The calendar month to
  downscale, e.g. '1' is all January months, '2' is February, and so on. }
\item{method}{Model type, e.g. \code{\link{lm}} og \code{\link{glm}}}
\item{swsm}{Stepwise screening, e.g. \code{\link{step}}. NULL skips stepwise screening}
\item{rmtrend}{TRUE for detrending the predicant and predictors (in the
  PCs) before calibrating the model}
\item{eofs}{Which EOF modes to include in the model training.}
\item{plot}{TRUE: plot the results}
\item{verbose}{TRUE: suppress output to the terminal.}
\item{station}{TRUE: convert monthly data to station class using
  \code{\link{combine.ds}}, else return a list of different monthly DS-results.}
\item{area.mean.expl}{When TRUE, subtract the area mean for the domain
  and use as a the first co-variate before the PCs from the EOF analysis.}
}

\value{
  The downscaling analysis returns a time series representing the local
  climate, patterns of large-scale anomalies associated with this,
  ANOVA, and analysis of residuals. Care must be taken when using this
  routine to infer local scenarios: check the R2 and p-values to check
  wether the calibration yielded an appropriate model. It is also
  important to examine the spatial structures of the large-scale
  anomalies assocaiated with the variations in the local climate: do
  these patterns make physical sense?

   It is a good idea to check whether there are any structure in
  the residuals: if so, then a linear model for the relationship between
  the large and small-scale structures may not be appropriate. It is
  furthermore important to experiment with predictors covering different
  regions [ref: Benestad
  (2001), "A comparison between two empirical downscaling strategies",
  \emph{Int. J. Climatology}, \bold{vol 21}, Issue 13, pp.1645--1668. DOI
  10.1002/joc.703].

  There is a cautionary tale for how the results can be misleading if
  the predictor domain in not appropriate: domain for northern Europe
  used for sites in Greenland [ref: Benestad (2002),
  "Empirically downscaled temperature scenarios for northern Europe
  based on a multi-model ensemble", \emph{Climate Research}, \bold{vol
  21 (2)}, pp.105--125. \url{http://www.int-res.com/abstracts/cr/v21/n2/index.html}]
}
\author{R.E. Benestad}
\examples{
# One exampe doing a simple ESD analysis:
X <- t2m.ERA40(lon=c(-40,50),lat=c(40,75))
data(Oslo)
#X <- OptimalDomain(X,Oslo)
Y <- DS(Oslo,X)
plot(Y)
str(Y)

# Look at the residual of the ESD analysis
y <- as.residual(Y)
plot(y)

# Check the residual: dependency to the global mean temperature?
T2m <- (t2m.ERA40())
yT2m <- merge.zoo(y,T2m)
plot(coredata(yT2m[,1]),coredata(yT2m[,2]))

data(t2m.DNMI)
y <- station.eca("Oslo")
X <- EOF(t2m.DNMI,mon=1)
ds <- DS.month.eof(y,X)

# Example: downscale annual wet-day mean precipitation -calibrate over
# part of the record and use the other part for evaluation.
T2M <- as.annual(t2m.NCEP(lon=c(-10,30),lat=c(50,70)))
cal <- subset(T2M,it=c("1948-01-01","1980-01-01"))
pre <- subset(T2M,it=c("1981-01-01","2013-01-01"))
comb <- combine(cal,pre)
X <- EOF(comb)
data(bjornholt)
y <- as.annual(bjornholt,FUN="exceedance")
z <- DS(y,X)
plot(z)

lon <- c(-12,37)
lat <- c(52,72)
ylim <- c(-6,6)
t2m <- t2m.NCEP(lon=lon,lat=lat)
T2m <- t2m.NorESM.M(lon=lon,lat=lat)
data(Oslo)
X <- combine(t2m,T2m)

eof <- EOF(X,it=7)
ds <- DS(Oslo,eof)
plot(ds)

DS(Oslo,X,station=FALSE) -> y
Y <- combine.ds.comb(y)
plot(Y)

data(ferder)
t2m <- t2m.NCEP(lon=c(-30,50),lat=c(40,70))
slp <- slp.NCEP(lon=c(-30,50),lat=c(40,70))
T2m <- as.4seasons(t2m)
SLP <- as.4seasons(slp)
X <- EOF(T2m,it=1)
Z <- EOF(SLP,it=1)
y <- ferder
sametimescale(y,X) -> z
ym <- as.4seasons(y,FUN="mean")
ys <- as.4seasons(y,FUN="sd")
dsm <- DS(ym,X)
dss <- DS(ys,Z)
}
\keyword{models}
\keyword{multivariate}
\keyword{ts}
\keyword{spatial}
