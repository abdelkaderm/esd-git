# This function maps a longitude-latitude grid onto a sphere. This
# function will be embeeded in map as an option.
#" c("lonlat","sphere","NP","SP")
# First transform longitude (theta) and latitude (phi) to cartesian
# coordinates:
#
# (theta,phi) -> (x,y,z) = r
#
# Use a transform to rotate the sphere through the following matrix
# product:
#
# ( x' )    ( a1  b1  c1 )  ( x )
# ( y' ) =  ( a2  b2  c2 )  ( y )
# ( z' )    ( a3  b3  c3 )  ( z )
#
# There can be three different rotation, about each of the axes
# For 90-degree rotatins, e.g. aroud the z-axis:
# Z = 90 (X = Y = 0): x' = y; y' = -x: z'= z
# a1 = cos(Z) ; b1=sin(Z); c1=cos(Z);
# a2 = -sin(Z); b2=cos(Z); c2=cos(Z)
# a3 = cos(Z) ; b3=cos(Z); c3=sin(Z)
# Y = 90 (Z = X = 0): x' = -z; z' = x; y' = y
# a1= cos(Y); b1 = cos(Y); c1=-sin(Y);
# a2= cos(Y); b2 = sin(Y); c2= cos(Y);
# a3= sin(Y); b3 = cos(Y); c3= cos(Y)
# X = 90 (Y = Z = 0): x' = x; z' = y; y' = - z
# a1 = sin(X); b1 = cos(X); c1 = cos(X)
# a2 = cos(X); b2 = cos(X); c2 = -sin(X);
# a3 = cos(X); b3 = sin(X), c3 = cos(X)
#
# a1 =  cosYcosZ; b1 = cosXsinZ; c1= -cosXsinY
# a2 = -cosXsinZ; b2 = cosXcosZ; c2= -sinXcosY
# a3 =  cosXsinY; b3 = sinXcosZ; c3=  cosXcosY
#
# Rasmus E. Benestad
# 14.04.2013


rotM <- function(x=0,y=0,z=0) {
  X <- -pi*x/180; Y <- -pi*y/180; Z <- -pi*z/180
  cosX <- cos(X); sinX <- sin(X); cosY <- cos(Y)
  sinY <- sin(Y); cosZ <- cos(Z); sinZ <- sin(Z)
  rotM <- rbind( c( cosY*cosZ, cosY*sinZ,-sinY*cosZ ),
                 c(-cosX*sinZ, cosX*cosZ,-sinX*cosZ ),
                 c( sinY*cosX, sinX*cosY, cosX*cosY ) )
  return(rotM)
}

gridbox <- function(x,cols,density = NULL, angle = 45) {
#  if (length(x) != 5) {print(length(x)); stop("gridbox")}
# W,E,S,N
# xleft, ybottom, xright, ytop
  i <- round(x[9])
#  rect(x[1], x[3], x[2], x[4],col=cols[i],border=cols[i])
  polygon(c(x[1:4],x[1]),c(x[5:8],x[5]),
          col=cols[i],border=cols[i])
}

#angleofview <- function(r,P) {
#  angle <- acos( (P%*%r)/( sqrt(P%*%P)*sqrt(r%*%r) ) )
#  return(angle)
#}

map2sphere <- function(x,n=30,lonR=NULL,latR=NULL,axiR=0,new=TRUE,
                       what=c("fill","contour"),gridlines=TRUE,cols=NULL) {

  # Data to be plotted:
  lon <- attr(x,'longitude')
  lat <- attr(x,'latitude')
  # To deal with grid-conventions going from north-to-south or east-to-west:
  srtx <- order(attr(x,'longitude')); lon <- lon[srtx]
  srty <- order(attr(x,'latitude')); lat <- lat[srty]
  map <- x[srtx,srty]
  param <- attr(x,'variable')
  unit <- attr(x,'unit')
  
  # Rotatio:
  if (is.null(lonR)) lonR <- mean(lon)  # logitudinal rotation
  if (is.null(latR)) latR <- mean(lat)  # Latitudinal rotation
  # axiR: rotation of Earth's axis

  # coastline data:
  data("geoborders",envir=environment())
  ok <- is.finite(geoborders$x) & is.finite(geoborders$y)
  theta <- pi*geoborders$x[ok]/180; phi <- pi*geoborders$y[ok]/180
  x <- sin(theta)*cos(phi)
  y <- cos(theta)*cos(phi)
  z <- sin(phi)

# Calculate contour lines if requested...  
#contourLines
  lonxy <- rep(lon,length(lat))
  latxy <- sort(rep(lat,length(lon)))
  map<- c(map)

# Remove grid boxes with missign data:
  ok <- is.finite(map)
  #print(paste(sum(ok)," valid grid point"))
  lonxy <- lonxy[ok]; latxy <- latxy[ok]; map <- map[ok]

# Define the grid box boundaries:
  dlon <- min(abs(diff(lon))); dlat <- min(abs(diff(lat)))
  Lon <- rbind(lonxy - 0.5*dlon,lonxy + 0.5*dlon,
               lonxy + 0.5*dlon,lonxy - 0.5*dlon)
  Lat <- rbind(latxy - 0.5*dlat,latxy - 0.5*dlat,
               latxy + 0.5*dlat,latxy + 0.5*dlat)
  Theta <- pi*Lon/180; Phi <- pi*Lat/180

# Transform -> (X,Y,Z):
  X <- sin(Theta)*cos(Phi)
  Y <- cos(Theta)*cos(Phi)
  Z <- sin(Phi)
  #print(c( min(x),max(x)))

# Define colour palette:
  if (is.null(cols)) cols <- colscal(n=n) else
  if (length(cols)==1) {
     palette <- cols
     cols <- colscal(palette=palette,n=n)
  }
  nc <- length(cols)
  index <- round( nc*( map - min(map) )/
                   ( max(map) - min(map) ) )

# Rotate coastlines:
  a <- rotM(x=0,y=0,z=lonR) %*% rbind(x,y,z)
  a <- rotM(x=latR,y=0,z=0) %*% a
  x <- a[1,]; y <- a[2,]; z <- a[3,]

# Grid coordinates:
  d <- dim(X)
  #print(d)

# Rotate data grid:  
  A <- rotM(x=0,y=0,z=lonR) %*% rbind(c(X),c(Y),c(Z))
  A <- rotM(x=latR,y=0,z=0) %*% A
  X <- A[1,]; Y <- A[2,]; Z <- A[3,]
  dim(X) <- d; dim(Y) <- d; dim(Z) <- d
  #print(dim(rbind(X,Z)))

# Plot the results:
  if (new) dev.new()
  par(bty="n",xaxt="n",yaxt="n")
  plot(x,z,pch=".",col="grey90",xlab="",ylab="")

# plot the grid boxes, but only the gridboxes facing the view point:
  Visible <- colMeans(Y) > 0
  X <- X[,Visible]; Y <- Y[,Visible]; Z <- Z[,Visible]
  index <- index[Visible]
  apply(rbind(X,Z,index),2,gridbox,cols)
  # c(W,E,S,N, colour)
  # xleft, ybottom, xright, ytop

# Plot the coast lines  
  visible <- y > 0
  points(x[visible],z[visible],pch=".")
  #plot(x[visible],y[visible],type="l",xlab="",ylab="")
  lines(cos(pi/180*1:360),sin(pi/180*1:360))

# Add contour lines?


# Add grid ?


# Colourbar:  
  par(fig = c(0.3, 0.7, 0.05, 0.10),mar=rep(0,4),cex=0.8,
      new = TRUE, mar=c(1,0,0,0), xaxt = "s",yaxt = "n",bty = "n")
  #print("colourbar")
  breaks <- round( nc*(seq(min(map),max(map),length=nc)- min(map) )/
                   ( max(map) - min(map) ) )
  bar <- cbind(breaks,breaks)
  image(seq(min(map),max(map),length=nc),c(1,2),bar,col=cols)

  par(bty="n",xaxt="n",yaxt="n",xpd=FALSE,
      fig=c(0,1,0,1),new=TRUE)
  plot(c(0,1),c(0,1),type="n",xlab="",ylab="")
  text(0.1,0.95,param,cex=1.5,pos=4)
  text(0.72,0.002,unit,pos=4)  
  
  #result <- data.frame(x=colMeans(Y),y=colMeans(Z),z=c(map))
  result <- NULL # For now...
  invisible(result)
}

#map2sphere(x)
