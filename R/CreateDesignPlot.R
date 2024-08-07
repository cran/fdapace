#' Create design plots for functional data. See Yao, F., Müller, H.G., Wang, J.L. (2005). Functional
#' data analysis for sparse longitudinal data. J. American Statistical Association 100, 577-590
#' for interpretation and usage of these plots. 
#' This function will open a new device as default. 
#'
#' @param Lt a list of observed time points for functional data
#' @param obsGrid a vector of sorted observed time points. Default are the 
#' unique time points in Lt.
#' @param isColorPlot an option for colorful plot: 
#'                    TRUE: create color plot with color indicating counts
#'                    FALSE: create black and white plot with dots indicating observed time pairs
#' @param noDiagonal an option specifying plotting the diagonal design points:
#'                   TRUE:  remove diagonal time pairs
#'                   FALSE:  do not remove diagonal time pairs
#' @param addLegend Logical, default TRUE
#' @param ... Other arguments passed into \code{plot()}. 
#'
#' @examples
#' set.seed(1)
#' n <- 20
#' pts <- seq(0, 1, by=0.05)
#' sampWiener <- Wiener(n, pts)
#' sampWiener <- Sparsify(sampWiener, pts, 10)
#' CreateDesignPlot(sampWiener$Lt, sort(unique(unlist(sampWiener$Lt))))
#' @export

CreateDesignPlot = function(Lt, obsGrid = NULL, isColorPlot=TRUE, noDiagonal=TRUE, addLegend= TRUE, ...){
  
  if( toString(class(Lt)) != 'list'){
    stop("You do need to pass a list argument to 'CreateDesignPlot'!");
  }
  if( is.null(obsGrid)){
    obsGrid = sort(unique(unlist(Lt)))
  }
  
  args1 <- list( main="Design plot", xlab= 'Observed time grid', ylab= 'Observed time grid', addLegend = addLegend)
  inargs <- list(...)
  args1[names(inargs)] <- inargs 
  
  
  # Check if we have very dense data (for visualization) on a regular grid
  if( (length(obsGrid) > 101) & all(sapply(Lt, function(u) identical(obsGrid, u)))){
    res = matrix(length(Lt), nrow = 101, ncol = 101)
    obsGrid = approx(x = seq(0,1,length.out = length(obsGrid)), y = obsGrid, 
                     xout = seq(0,1,length.out = 101))$y
  } else {
    res = DesignPlotCount(Lt, obsGrid, noDiagonal, isColorPlot)
  }
  
  oldpty <- par()[['pty']]
  on.exit(par(pty=oldpty))
  par(pty="s")
  if(isColorPlot == TRUE){
    createColorPlot(res, obsGrid, args1)
  } else {
    createBlackPlot(res, obsGrid, args1)
  }
  
}

createBlackPlot = function(res, obsGrid, args1){
  
  args1$addLegend = NULL
  if( is.null(args1$col)){
    args1$col = 'black'
  }
  if (is.null(args1$cex)){
    args1$cex = 0.33
  }
  if (is.null(args1$pch)){
    args1$pch = 19
  }
  
  u1 = as.vector(res)
  u2 = as.vector(t(res))
  t1 = rep(obsGrid, times = length(obsGrid) )
  t2 = rep(obsGrid, each = length(obsGrid)) 
  do.call( plot, c(args1, list( x = t1[u1 != 0], y = t2[u2 !=0] ) ) )  
  
}

createColorPlot = function(res, obsGrid, args1){
  
  res[res > 4] = 4;
  notZero <- which(res != 0, arr.ind=TRUE)
  nnres <- res[notZero]
  
  addLegend <- args1$addLegend;
  args1$addLegend <- NULL 
  
  if ( is.null(args1$col) ){
    colVec <- c(`1`='black', `2`='blue', `3`='green', `4`='red')
    args1$col = colVec[nnres];
  } else {
    colVec = args1$col;
  }
  
  if ( is.null(args1$pch) ){
    pchVec <- rep(19, length(colVec))
    args1$pch = pchVec[nnres];
  } else {
    pchVec = args1$pch;
  }
  
  if ( is.null(args1$cex) ){
    cexVec <- seq(from=0.3, by=0.1, length.out=length(colVec))
    args1$cex <- cexVec[nnres]
  } else {
    cexVec <- args1$cex;
  }
 
  do.call( plot, c(args1, list( x = obsGrid[notZero[, 1]], y = obsGrid[notZero[, 2]]) ))

  pars <- par()
  # plotWidth <- (pars[['fin']][1] - sum(pars[['mai']][c(2, 4)]))
  if(addLegend){
    if (!identical(unique(nnres), 1)){
          legend('right', c('1','2','3','4+'), pch = pchVec, col=colVec, pt.cex=1.5, title = 'Count',bg='white', 
                 inset=-pars[['mai']][4] / pars[['pin']][1]  * 1.5, xpd=TRUE)
    }
  }
}


