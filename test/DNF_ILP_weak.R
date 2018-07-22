DNF_ILP_weak <- function(X, Y, W, K, M, lambda, sens, spec, addcons) {
  
  if (length(as.list(match.call())) - 1 != 9) {
    stop("Please specify all inputs.")
  }
  
  N <- NROW(X)
  P <- NCOL(X)
  
  print(N)
  print(P)
  ##Variables
  # selector variables S and S';
  # output of DNF AND gates and label for each sample (K+1)*N;
  NoV <- 2 * P * K + (K + 1) * N
  
  ##Variables bound
  lb <- matrix(0, nrow = NoV, ncol = 1)
  ub <- matrix(1, nrow = NoV, ncol = 1)
  
  ##Variables binary?
  ctype <- rep('I', times = NoV)
  
  ##Optimizing function
  print('Constructing optimizing function...')
  optfun <- matrix(0, nrow = NoV, ncol = 1)
  
  #error
  Ip <- which(Y == 1)
  In <- which(Y == 0)
  Io <- (2 * P * K + K * N + 1):(2 * P * K + (K + 1) * N)
  optfun[Io[In]] <- W[In] #error if mispredicting a 0
  optfun[Io[Ip]] <- -W[Ip] #error if mispredicting a 1
  
  #model complexity penalty
  if (M == -1) {
    optfun[1:(2 * P * K)] <- lambda
  }
  
  ##Constraints and their bounds
  print('Constructing constraints...')
  #number of constraints
  NoC <- P * K + N * K + N * K + N + N
  if (M > 0 & M < P) {
    NoC <- NoC + K
  }
  if ((sens > 0 & sens <= 1) | (sens < 0 & sens >= -1)) {
    NoC <- NoC + 1
  }
  if ((spec > 0 & spec <= 1) | (spec < 0 & spec >= -1)) {
    NoC <- NoC + 1
  }
  NoC <- NoC + K * nrow(addcons)
  
  #number of nonzero elements
  NoZ = 2 * P * K + N * K + K * N * P + N * K + K * N * P + N + N * K + N + N * K
  if (M > 0 & M < P) {
    NoZ <- NoZ + 2 * P * K
  }
  if ((sens > 0 & sens <= 1) | (sens < 0 & sens >= -1)) {
    NoZ <- NoZ + length(Ip)
  }
  if ((spec > 0 & spec <= 1) | (spec < 0 & spec >= -1)) {
    NoZ <- NoZ + length(In)
  }
  if (NROW(addcons)) {
    for (c in 1:NROW(addcons)) {
      NoZ <- NoZ + K * 2 * length(addcons[c, 1])
    }
  }

  #make index variables for sparse matrix
  I <- matrix(0, nrow = NoZ, ncol = 1)
  J <- matrix(0, nrow = NoZ, ncol = 1)
  Q <- matrix(0, nrow = NoZ, ncol = 1)
  
  consub <- matrix(0, nrow = NoC, ncol = 1)
  conr <- 0 #setting constraint number
  conz <- 0 #setting number of nonzero elements
  
  #Constraint 1 OR between S and S'
  p <- 1:P
  for(k in 1:K) {
    ix <- conz + p
    I[ix] <- conr + (k - 1) * P + p
    J[ix] <- (k - 1) * P + p
    Q[ix] <- 1
    conz <- conz + P
    ix <- conz + p
    I[ix] <- conr + (k - 1) * P + p
    J[ix] <- P * K + (k - 1) * P + p
    Q[ix] <- 1
    consub[conr + (k - 1) * P + p] <- 1
    conz <- conz + P
  }
  conr <- P * K
  conz <- 2 * P * K
  
  #Constraint 2 AND for kth conjunctive term
  k <- 1:K
  for (n in 1:N) {
    PosSet = which(X[n, ] == 1);
    NegSet = which(X[n, ] == 0);
    LPS = length(PosSet);
    LNS = length(NegSet);
    ix = conz + k;
    I[ix] = conr + (k - 1) * N + n;
    J[ix] = 2 * P * K + (k - 1) * N + n;
    Q[ix] = P;
    conz = conz + K;
    ix = conz + k;
    I[ix] = conr + N * K + (k - 1) * N + n;
    J[ix] = 2 * P * K + (k - 1) * N + n;
    Q[ix] = -1;
    conz = conz + K;
    for (kk in 1:K) {
      ix = conz + (1:LPS);
      I[ix] = conr + (kk - 1) * N + n;
      if (length(PosSet) > 0) {
        J[ix] = P * K + (kk - 1) * P + PosSet;
      }
      Q[ix] = 1;
      conz = conz + LPS;
      ix = conz + (1:LNS);
      I[ix] = conr + (kk - 1) * N + n;
      J[ix] = (kk - 1) * P + NegSet;
      Q[ix] = 1;
      conz = conz + LNS;
      ix = conz + (1:LPS);
      I[ix] = conr + N * K + (kk - 1) * N + n;
      if (length(PosSet) > 0) {
        J[ix] = P * K + (kk - 1) * P + PosSet;
      }
      Q[ix] = -1;
      conz = conz + LPS;
      ix = conz + (1:LNS);
      I[ix] = conr + N * K + (kk - 1) * N + n;
      J[ix] = (kk - 1) * P + NegSet;
      Q[ix] = -1;
      conz = conz + LNS;
    }
    consub[conr + (k - 1) * N + n] = P;
    consub[conr + N * K + (k - 1) * N + n] = -1;
  }
  conr <- P * K + N * K + N * K
  conz <- 2 * P * K + N * K + K * N * P + N * K + K * N * P
  
  #Constraint 3 BIG OR between the K disjunctive terms
  n <- 1:N
  ix <- conz + n
  I[ix] <- conr + n
  J[ix] <- 2 * P * K + N * K + n
  Q[ix] <- -K
  conz <- conz + N
  ix <- conz + n
  I[ix] <- conr + N + n
  J[ix] <- 2 * P * K + N * K + n
  Q[ix] <- 1
  conz <- conz + N
  k <- 1:K
  for (nn in 1:N) {
    ix <- conz + k
    I[ix] <- conr + nn
    J[ix] <- 2 * P * K + seq(from = nn, to = N * K, by = N)
    Q[ix] <- 1
    conz <- conz + K
    ix <- conz + k
    I[ix] <- conr + N + nn
    J[ix] <- 2 * P * K + seq(from = nn, to = N * K, by = N)
    Q[ix] <- -1
    conz <- conz + K
  }
  consub[conr + n] <- 0
  consub[conr + N + n] <- 0
  conr <- P * K + N * K + N * K + N + N
  conz <- 2 * P * K + N * K + K * N * P + N * K + K * N * P + N + N * K + N + N * K
  
  if (M > 0 & M < P) {
    #Limit number of terms per disjunct
    p = 1:P
    for (k in 1:K) {
      ix <- conz + p
      I[ix] <- conr + k
      J[ix] <- ((k - 1) * P + 1):((k - 1) * P + P)
      Q[ix] <- 1
      conz <- conz + P
      ix <- conz + p
      I[ix] <- conr + k
      J[ix] <- (P * K + (k - 1) * P + 1):(P * K + (k - 1) * P + P)
      Q[ix] <- 1
      conz <- conz + P
      consub[conr + k] <- M
    }
    conr <- conr + K
  }
  
  if (sens > 0 & sens <= 1) {
    #Sensitivity constraint
    NoP <- sum(Y == 1) #Number of positives
    ix <- conz + (1:length(Ip))
    I[ix] <- conr + 1
    J[ix] <- Io[Ip]
    Q[ix] <- -1
    conz <- conz + length(Ip)
    consub[conr + 1] <- -NoP * sens
    conr <- conr + 1
  } else if (spec < 0 & spec >= - 1) {
    sens <- -sens
    #Continuous sensitivity constraint
    NoP <- sum(W[Ip]) #Number of positives weighted by error
    ix <- conz + (1:length(Ip))
    I[ix] <- conr + 1
    J[ix] <- Io[Ip]
    Q[ix] <- -W[Ip]
    conz <- conz + length(Ip)
    consub[conr + 1] <- -NoP * sens
    conr <- conr + 1
  }
  
  if (spec > 0 & spec <= 1) {
    #Specificity constraint
    NoN <- sum(Y == 0) #Number of negatives
    ix <- conz + (1:length(In))
    I[ix] <- conr + 1
    J[ix] <- Io[In]
    Q[ix] <- 1
    conz <- conz + length(In)
    consub[conr + 1] <- NoN * (1 - spec)
    conr <- conr + 1
  } else if (spec < 0 & spec >= -1) {
    spec <- -spec
    #Continuous Specificity constraint
    NoN <- sum(W[In]) #Number of negatives weighted by error
    ix <- conz + (1:length(In))
    I[ix] <- conr + 1
    J[ix] <- Io[In]
    Q[ix] <- W[In]
    conz <- conz + length(In)
    consub[conr + 1] <- NoN * (1 - spec)
    conr <- conr + 1
  }
  
  if (nrow(addcons) > 0) {
    #Additional constraints on allowed features
    for (c in 1:nrow(addcons)) {
      if (addcons[c, 3] == 's') {
        for (k in 1:K) {
          ix <- conz + (1:length(addcons[c, 1]))
          I[ix] <- conr + k
          J[ix] <- (k - 1) * P + addcons[c, 1]
          Q[ix] <- 1
          conz <- conz + length(addcons[c, 1])
          ix <- conz + (1:length(addcons[c, 1]))
          I[ix] <- conr + k
          J[ix] <- P * K + (k - 1) * P + addcons[c, 1]
          Q[ix] <- 1
          conz <- conz + length(addcons[c, 1])
          consub[conr + k] <- addcons[c, 2]
        }
        conr <- conr + K
      } else if (addcons[c, 3] == 'g') {
        for(k in 1:K) {
          ix <- conz + (1:length(addcons[c, 1]))
          I[ix] <- conr + k
          J[ix] <- (k - 1) * P + addcons[c, 1]
          Q[ix] <- -1
          conz <- conz + length(addcons[c, 1])
          ix <- conz + (1:length(addcons[c, 1]))
          I[ix] <- conr + k
          J[ix] <- P * K + (k - 1) * P + (k - 1) * P + addcons[c, 1]
          Q[ix] <- -1
          conz <- conz + length(addcons[c, 1])
          consub[conr + k] <- -addcons[c, 2]
        }
        conr <- conr + K
      }
    }
  }
  
  library(Matrix)
  cons <- sparseMatrix(i = as.vector(I),
                       j = as.vector(J),
                       x = as.vector(Q),
                       dims = c(NoC, NoV))
  print("aaaaaaaaa---------------------------------------------------")
  #print(dim(lb))
  #print(dim(as.matrix(cons)))
  #print(dim(optfun))
  

  return(list(optfun, cons, consub, lb, ub, ctype))
}