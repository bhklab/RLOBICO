#' Show the Lobico Formula
#'
#' Displays the lobico formula used in the logical model
#'
#' @param SolMat The solution matrix
#' @param K The number of disjunctive terms
#' @param M The maximum number of selected features per disjunctive term
#' @param X1 The parameter matrix
#' 
#' @return The string represents the solution
#' 
#' @export
#'
.showformula <- function(SolMat, K, M, X1) {
  
  if (missing('X1')) {
    X1 <- data.frame(NA, nrow = ncol(SolMat), nrow = 1)
    for (n in 1:length(X1)) {
      X1[[n]] <- paste('x', toString(n))
    }
  }
  
  
  if (K <= M) {
    
    str <- NULL
    for (k in 1:K) {
      pos <- which(SolMat[k, ] != 0)
      for(p in 1:length(pos)) {
        if (SolMat[k, pos[p]] == -1) {
          str <- paste0(str, '~')
        }
        str <- paste0(str, X1[[pos[p]]], ' ')
        if (p != length(pos)) {
          str <- paste0(str, ' & ')
        } else {
          if (k != K) {
            str <- paste0(str, ' | ')
          }
        }
      }
    }
    
  } else {
    
    Ktemp <- K
    K <- M
    M <- Ktemp
    
    str <- NULL
    # str <- matrix(NULL)
    for (k in 1:K) {
      pos <- which(SolMat[k, ] != 0)
      for (p in 1:length(pos)) {
        if (SolMat[k, pos[p]] == -1) {
          str <- paste0(str, '~')
        }
        #str <- paste(str, X1[[pos[p]]])
        str <- paste0(str, X1[[pos[p]]], ' ')
        if (p != length(pos)) {
          str <- paste0(str, ' | ')
        } else {
          if (k != K) {
            str <- paste0(str, ' & ')
          }
        }
      }
    }
  }
  return(str)
}