#' Plot FPCA object. 
#'
#' Plotting the results of an FPCA, including printing the design plot, mean function, scree-plot
#' and the first three eigenfunctions for a functional sample. If provided with a derivative options object (?FPCAder), it will  return the 
#' differentiated mean function and first two principal modes of variation for 50\%, 75\%, 100\%, 125\% and 150\% of the defined bandwidth choice.
#'
#' @param x An FPCA class object returned by FPCA().
#' @param openNewDev A logical specifying if a new device should be opened - default: FALSE
#' @param addLegend A logical specifying whether to add legend.
#'
#' @details The black, red, and green curves stand for the first, second, and third eigenfunctions, respectively. 
#' \code{plot.FPCA} is currently implemented only for the original function, but not a derivative FPCA object.

#'
#' @examples
#' set.seed(1)
#' n <- 20
#' pts <- seq(0, 1, by=0.05)
#' sampWiener <- Wiener(n, pts)
#' sampWiener <- Sparsify(sampWiener, pts, 10)
#' res1 <- FPCA(sampWiener$Ly, sampWiener$Lt, 
#'             list(dataType='Sparse', error=FALSE, kernel='epan', verbose=FALSE))
#' plot(res1)
#' @export
plot.FPCA <- function(x, openNewDev = FALSE, addLegend=TRUE, ...){ 

  fpcaObj <- x
  
  oldPar <- par(no.readonly=TRUE)
  if (any(oldPar[['pin']] < 0)) {
    stop('Figure margin too large')
  } else {
    on.exit(par(oldPar))
  }
  
  if(!'FPCA' %in% class(fpcaObj)) {
    stop("Input class is incorrect; plot.FPCA() is only usable for FPCA objects.")
  } else {
    
    #if(is.null(derOptns) || !is.list(derOptns)){ 
    t = fpcaObj$inputData$Lt
    if(openNewDev){ 
      dev.new(width=6.2, height=6.2, noRStudioGD=TRUE) ; 
    }
    fves = fpcaObj$cumFVE
    mu = fpcaObj$mu
    obsGrid = fpcaObj$obsGrid      
    workGrid = fpcaObj$workGrid
    
    par(mfrow=c(2,2))
    
    ## Make Design plot
    CreateDesignPlot(t, addLegend=addLegend, noDiagonal=fpcaObj$optns$error)
    
    ## Make Mean trajectory plot
    plot( workGrid, mu, type='l', xlab='s',ylab='', main='Mean function', panel.first = grid(), axes = TRUE)   

    ## Make Scree plot
    CreateScreePlot(fpcaObj);
    
    ## Make Phi plot
    K = ncol(fpcaObj$phi);
    k =1;
    if(K>3){
      k = 3;
    } else {
      k = K;
    } # paste(c("First ", as.character(3), " eigenfunctions"),collapse= '')
    if (addLegend) {
      ## pin does not work for Rstudio
      # newpin <- par()[['pin']]
      # newpin[1] <- newpin[1] * 0.8
      # par(pin = newpin)
      newplt <- par()[['plt']]
      newplt[2] <- newplt[1] + 0.85 * (newplt[2] - newplt[1])
      par(plt=newplt)
    }
    matplot(workGrid, fpcaObj$phi[,1:k], type='n', 
            main=paste(collapse='', c("First ", as.character(k), " eigenfunctions"))  , xlab='s', ylab='') 
    abline(h=0, col='gray9')
    grid()
    matlines(workGrid, fpcaObj$phi[,1:k] ) 
    pars <- par()
    if (addLegend) {
      legend("right", col=1:k, lty=1:k, legend = do.call(expression, sapply(1:k, function(u) return(bquote(phi[ .(u) ])))), border = FALSE,  xpd=TRUE, inset=-pars[['mai']][4] / pars[['pin']][1] * 1.8, seg.len=1.2)
    }
    # } else {
    #   
    #   derOptns <- SetDerOptions(fpcaObj,derOptns = derOptns) 
    #   p <- derOptns[['p']]
    #   method <- derOptns[['method']]
    #   bw <- derOptns[['bw']]
    #   kernelType <- derOptns[['kernelType']]
    #   k <- derOptns[['k']]
    #   if(p==0){
    #     stop("Derivative diagnostics are inapplicable when p = 0")
    #   }
    #   
    #   bwMultipliers = seq(0.50,1.5,by=0.25)
    #   yy = lapply( bwMultipliers *  bw, function(x) FPCAder(fpcaObj, list(p=p, method = method, kernelType = kernelType, k = k, bw = x)))
    #   
    #   par(mfrow=c(1,3))
    #   
    #   Z = rbind(sapply(1:5, function(x) yy[[x]]$muDer));
    #   matplot(x = fpcaObj$workGrid, lty= 1, type='l',  Z, ylab= expression(paste(collapse = '', 'd', mu, "/ds")), 
    #           main= substitute(paste("Derivatives of order ", p, " of ", mu)), xlab = 's')
    #   grid(); legend('topright', lty = 1, col=1:5, legend = apply( rbind( rep('bw: ',5), bwMultipliers * bw), 2, paste, collapse = ''))
    #   
    #   Z = rbind(sapply(1:5, function(x) yy[[x]]$phiDer[,1]));
    #   matplot(x = fpcaObj$workGrid, lty= 1, type='l',  Z,   ylab= expression(paste(collapse = '', 'd', phi[1], "/ds")), 
    #           main= substitute(paste("Derivatives of order ", p, " of ", phi[1])), xlab = 's')
    #   grid(); legend('topright', lty = 1, col=1:5, legend = apply( rbind( rep('bw: ',5), bwMultipliers * bw), 2, paste, collapse = ''))
    #   
    #   Z = rbind(sapply(1:5, function(x) yy[[x]]$phiDer[,2]));
    #   matplot(x = fpcaObj$workGrid, lty= 1, type='l',  Z, ylab= expression(paste(collapse = '', 'd', phi[2], "/ds")), 
    #           main= substitute(paste("Derivatives of order ", p, " of ", phi[2])), xlab = 's')
    #   grid(); legend('topleft', lty = 1, col=1:5, legend = apply( rbind( rep('bw: ',5), bwMultipliers * bw), 2, paste, collapse = ''))
    
  }
}

