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