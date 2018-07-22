predictResponse <- function(xconc,
                            yconc,
                            xpars,
                            ypars,
                            model = c('ResponseAdditivity',
                                      'LoeweAdditivity',
                                      'BlissIndependence',
                                      'HighestSingleAgent'),
                            conc_as_log = TRUE,
                            viability_as_pct = TRUE) {
  
  SanityCheck(args)
  
  if (!conc_as_log) {
    xconc <- log10(xconc)
    yconc <- log10(yconc)
    xpars[3] <- log10(xpars[3])
    ypars[3] <- log10(ypars[3])
  }
  
  if (viability_as_pct) {
    xpars[2] <- xpars[2] / 100
    ypars[2] <- ypars[2] / 100
  }
  
  if (model == 'ResponseAdditivity') {
    return((.Hill(xconc, xpars) + .Hill(yconc, ypars) - 1) * (1 + 99 * viability_as_pct))
  } else if (model == 'LoeweAdditivity') {
    if (xpars[1] != ypars[1] || xpars[2] != ypars[2]) {
      stop('Loewe Additivity is not appropriate to model this interaction.')
    } else {
      return(.Hill(log10(10 ^ xconc + 10 ^ yconc * 10 ^ xpars[3] / 10 ^ ypars[3]), xpars) * (1 + 99 * viability_as_pct))
    }
  } else if (model == 'BlissIndependence') {
    return(.Hill(xconc, xpars) * .Hill(yconc, ypars) * (1 + 99 * viability_as_pct))
  } else {
    return(min(.Hill(xconc, xpars), .Hill(yconc, ypars)) * (1 + 99 * viability_as_pct))
  }
  
}