.parsetsv <- function(file) {
  
  ## check number of tabs
  fid <- fopen(file)
  NL <- 10
  tline <- data.frame(0, nrow = NL, ncol = 1)
  not <- matrix(0, nrow = NL, ncol = 1)
  for (n in 1:10) {
    tline[[n]] <- fgetl(fid)
    display(tline[[n]])
    not[n] <- sum(as.double(tline[[n]]) == 9)
  }
  fclose(fid)
  
  ##Create format string
  unot <- unique(not)
  if (length(unot) != 1) {
    stop(as.string(unot))
  } else {
    rsh <- matrix(NULL, nrow = 0)
    rsd <- matrix(NULL, nrow = 0)
    for (n in 1:(unot + 1)) {
      if (n > 1) {
        rsd <- cbind(rsd, '%n')
      } else {
        rsd <- cbind(rsd, '%s')
      }
      rsh <- cbind(rsh, '%s')
    }
  }
  
  ##read in header
  fid <- fopen(file)
  H <- textscan(fid, rsd, 'Delimiter', '\t')
  fclose(fid)
  
  ##read in data
  fid <- fopen(file)
  D <- textscan(fid, rsd, 'Delimiter', '\t', 'Headerlines', 1)
  fclose(fid)
  
  ##parse
  N <- length(D[[1]])
  P <- length(H) - 2
  
  Samples <- D[[1]]
  IC50s <- D[[2]]
  
  MutationMatrix <- matrix(NA, nrow = N, ncol = P)
  Features <- data.frame(NULL, nrow = 1, ncol = P)
  
  for (p in 1:P) {
    Features[[p]] <- H[[p + 2]][[1]]
    MutationMatrix[, p] <- D[[p + 2]]
  }
  
  return(Samples, Features, IC50s, MutationMatrix)
}