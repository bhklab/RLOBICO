.makeartificialdataset <- function(N, P, K, M, nX, nY) {
  
  #make dataset
  X = matrix(round(runif(N * P)), nrow = N)
  
  
  if (K <= M) {
    
    #randomly selecting inputs
    set <- data.frame(NA)
    SolMatT <- matrix(0, nrow = K, ncol = P)
    for (k in 1:K) {
      pos <- sample(P, size = P)
      pos <- pos[1:M]
      sig <- 2 * as.numeric(runif(M) > 1 / 2) - 1
      SolMatT[k, pos] <- sig
      set[[k]] <- pos * sig
    }
    
    #create binary output
    Y = matrix(0, nrow = N, ncol = 1)
    for (n in 1:length(set)) {
      tempvec <- matrix(1, nrow = N, ncol = 1)
      for (m in 1:length(set[[n]])){
        if (set[[n]][m] > 0) {
          tempvec <- as.numeric(tempvec&X[, set[[n]][m]])
        } else {
          tempvec <- as.numeric(tempvec&(!as.logical(X[, -set[[n]][m]])))
        }
      }
      Y <- as.numeric(Y|tempvec)
    }
    
  } else {
    
    #randomly selecting inputs
    set <- data.frame(NA)
    SolMatT <- matrix(0, nrow = M, ncol = P)
    for (m in 1:M) {
      pos <- sample(P, size = P)
      pos <- pos[1:K]
      sig <- 2 * as.numeric(runif(K) > 1 / 2) - 1
      SolMatT[m, pos] <- sig
      set[[m]] <- pos * sig
    }
    
    #create binary output
    Y <- matrix(1, nrow = N, ncol = 1)
    for (n in 1:length(set)) {
      tempvec <- matrix(0, nrow = N, ncol = 1)
      for (k in 1:length(set[[n]])) {
        if (set[[n]][k] > 0) {
          tempvec <- as.numeric(tempvec|X[, set[[n]][k]])
        } else {
          tempvec <- as.numeric(tempvec|(!as.logical(X[, -set[[n]][k]])))
        }
      }
      Y <- as.numeric(Y&tempvec)
    }
    
  }


#add noise to binary input matrix
XN <- runif(length(X)) < nX
X[XN == 1] <- !X[XN == 1]

#add noise to binary output to create continuous output variable
Y <- Y + nY * rnorm(length(Y))

#Create sample specific weight vector w using 0.5 as a binarization threshold
W <- abs(Y - 1 / 2)

#Binarize Y
Y <- as.numeric(Y > 1 / 2)

#Set equal class weights
W[Y == 1] <- W[Y == 1] / sum(W[Y == 1])
W[Y == 0] <- W[Y == 0] / sum(W[Y == 0])

#Set weight of samples from the Y=0 class as negative numbers
W[Y == 0] <- -W[Y == 0]
return(list(X, Y, W, SolMatT))
}