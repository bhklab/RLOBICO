computeICn <- function(conc, viability, pars, n, conc_as_log = TRUE, viability_as_pct = TRUE) {
  
  SanityCheck(args)
  
  if (!missing(conc) && !missing(viability)) {
    if (!conc_as_log) {
      conc <- log10(conc)
    }
    
    if (viability_as_pct) {
      viability <- viability / 100
      n <- n / 100
    }
    
    pars <- .logLogisticRegression(conc, viability, conc_as_log = TRUE, viability_as_pct = FALSE)
    
  } else if (!missing(pars)) {
    
    if (!conc_as_log) {
      pars[3] <- log10(pars[3])
    }
    
    if (viability_as_pct) {
      pars[2] <- pars[2] / 100
      n <- n / 100
    }
    
  } else {
    
    stop("Insufficient information to calculate ICn. Please enter conc and viability or Hill parameters.")
    
  }
  
  if (n < pars[2] || n > 1) {
    
    return(NA)
    
  } else if (n == pars[2]) {
    
    return(Inf)
    
  } else if (n == 1) {
    
    return(ifelse(conc_as_log, -Inf, 0))
    
  } else {
    
    return(ifelse(conc_as_log,
                  log10(10 ^ pars[3] * ((n - 1) / (pars[2] - n)) ^ (1 / pars[1])),
                  10 ^ pars[3] * ((n - 1) / (pars[2] - n)) ^ (1 / pars[1])))
    
  }
  
}