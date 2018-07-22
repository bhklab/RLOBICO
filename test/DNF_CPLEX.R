DNF_CPLEX <- function(X, Y, W, K, M, lambda, sens, spec, addcons) {
  
  if (length(as.list(match.call())) - 1 != 9) {
    stop("Please specify all inputs.")
  }
  
  c(N, P) <- c(NROW(X), NCOL(X))
  
  ##Variables
  # selector variables S and S';
  # output of DNF AND gates and label for each sample (K+1)*N;
  # 1 : 2*P*K + (K+1)*N
  
  ##Variables bound
  lb <- matrix(0, nrow = 2 * P * K + (K + 1) * N, ncol = 1)
  ub <- matrix(1, nrow = 2 * P * K + (K + 1) * N, ncol = 1)
  
  ##Variables binary?
  ctype <- as.string('I' * matrix(1, nrow = 2 * P * K + (K + 1) * N, ncol = 1))
  
  ##Optimizing function
  print('Constructing optimizing function...')
  optfun <- matrix(0, nrow = 2 * P * K + (K + 1) * N, ncol = 1)
  
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
  NoC <- P * K + N * P * K + N * K + N * K + N
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
  cons <- matrix(0, nrow = NoC, ncol = 2 * P * K + (K + 1) * N)
  consub <- matrix(0, nrow = NoC, ncol = 1)
  conr <- 0 #setting constraint number
  
  #Constraint 1 OR between S and S'
  print('Constructing constraint 1...')
  for (p in 1:P) {
    for(k in 1:K) {
      cons[conr + (k - 1) * P + p, c((k - 1) * P + p, P * K + (k - 1) * P + p)] <- 1
      consub[conr + (k - 1) * P + p] <- 1
    }
  }
  conr <- P * K
  
  #Constraint 2 AND for kth disjunctive term
  print('Constructing constraint 2...')
  for (n in 1:N) {
    for (k in 1:K) {
      for (p in 1:P) {
        if (X[n, p] == 1) {
          cons[conr + (n - 1) * P * K + (k - 1) * P + p, c(2 * P * K + (k - 1) * N + n, P * K + (k - 1) * P + p)] <- 1
        } else {
          cons[conr + (n - 1) * P * K + (k - 1) * P + p, c(2 * P * K + (k - 1) * N + n, (k - 1) * P + p)] <- 1
        }
        consub[conr + (n - 1) * P * K + (k - 1) * P + p] <- 1
      }
    }
  }
  conr <- P * K + N * P * K
  
  for (n in 1:N) {
    for (k in 1:K) {
      PosSet <- which(X[n, ] == 1)
      NegSet <- which(X[n, ] == 0)
      cons[conr + (k - 1) * N + n, c(2 * P * K + (k - 1) * N + n, P * K + (k - 1) * P + PosSet, (k - 1) * P + NegSet)] <- -1
      #cons[conr + (k - 1) * N + n, 2 * P * K + (k - 1) * N + n] <- 1
      consub[conr + (k - 1) * N + n] <- -1
    }
  }
  conr <- P * K + N * P * K + N * K
  
  #Constraint 3 BIG OR between the K disjunctive terms
  print('Constructing constraint 3...')
  for(n in 1:N) {
    for (k in 1:K) {
      cons[conr + (k - 1) * N + n, 2 * P * K + N * K + n] <- -1
      cons[conr + (k - 1) * N + n, 2 * P * K + (k - 1) * N + n] <- 1
      consub[conr + (k - 1) * N + n] <- 0
    }
  }
  conr <- P * K + N * P * K + N * K + N * K
  
  for (n in 1:N) {
    cons[conr + n, 2 * P * K + N * K + n] <- 1
    cons[conr + n, 2 * P * K + seq(from = n, to = N * K, by = N)] <- -1
    consub[conr + n] <- 0
  }
  conr = P * K + N * P * K + N * K + N * K + N
  
  
  if (M > 0 & M < P) {
    #Limit number of terms per disjunct
    print('Constructing constraint 4...')
    for (k in 1:K) {
      cons[conr + k, c(((k - 1) * P + 1):((k - 1) * P + P), (P * K + (k - 1) * P + 1):(P * K + (k - 1) * P + P))] <- 1
      consub[conr + k] <- M
    }
    conr <- conr + K
  }
  
  if (sens > 0 & sens <= 1) {
    #Sensitivity constraint
    print('Constructing constraint 5...')
    NoP <- sum(Y == 1) #Number of positives
    cons[conr + 1, Io[Ip]] <- -1 #sum of TPs
    consub[conr + 1] <- -NoP * sens
    conr <- conr + 1
  } else if (spec < 0 & spec >= - 1) {
    sens <- -sens
    #Continuous sensitivity constraint
    print('Constructing constraint 5...')
    NoP <- sum(W[Ip]) #Number of positives weighted by error
    cons[conr + 1, Io[Ip]] <- -W[Ip] #sum of TPs
    consub[conr + 1] <- -NoP * sens
    conr <- conr + 1
  }
  
  if (spec > 0 & spec <= 1) {
    #Specificity constraint
    print('Constructing constraint 6...')
    NoN <- sum(Y == 0) #Number of negatives
    cons[conr + 1, Io[In]] <- 1 #sum of FPs
    consub[conr + 1] <- NoN * (1 - spec)
    conr <- conr + 1
  } else if (spec < 0 & spec >= -1) {
    spec <- -spec
    #Continuous Specificity constraint
    print('Constructing constraint 6...')
    NoN <- sum(W[In]) #Number of negatives weighted by error
    cons[conr + 1, Io[In]] <- W[In] #sum of FPs
    consub[conr + 1] <- NoN * (1 - spec)
    conr <- conr + 1
  }
  
  if (nrow(addcons) > 0) {
    #Additional constraints on allowed features
    print('Constructing constraint 7...')
    for (c in 1:nrow(addcons)) {
      if (addcons[c, 3] == 's') {
        for (k in 1:K) {
          cons[conr + k, c((k - 1) * P + addcons[c, 1], P * K + (k - 1) * P + (k - 1) * P + addcons[c, 1])] <- 1
          consub[conr + k] <- addcons[c, 2]
        }
        conr <- conr + K
      } else if (addcons[c, 3] == 'g') {
        for(k in 1:K) {
          cons[conr + k, c((k - 1) * P + addcons[c, 1], P * K + (k - 1) * P + (k - 1) * P + addcons[c, 1])] <- -1
          consub[conr + k] <- -addcons[c, 2]
        }
        conr <- conr + K
      }
    }
  }
  
  return(list(optfun, cons, consub, lb, ub, ctype))
}