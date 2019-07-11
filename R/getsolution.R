#' Get Lobico Model Solution
#'
#' Input model parameters and output result
#'
#' @param x The  matrix
#' @param K The number of disjunctive terms
#' @param M The maximum number of selected features per disjunctive term
#' @param P The number of rows of solution matrix
#' 
#' @return The solution matrix to the lobico model
#'
#' @export
#' 
.getsolution <- function(x, K, M, P) {
  
  if (K > M) {
    Ktemp <- K
    K <- M
    M <- Ktemp
    rm(Ktemp)
  }
  
  PM <- t(matrix(x[1:(P * K)], nrow = P, byrow = FALSE))
  MM <- t(matrix(x[(P * K + 1):(2 * P * K)], nrow = P, byrow = FALSE))
  return(PM - MM)
}