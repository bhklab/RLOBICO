## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
require(devtools)

## ----Installation--------------------------------------------------------
library(devtools)
devtools::install_github("bhklab/RLOBICO", ref="RLOBICO_CRAN")
library(rlobico)

## ----dataLoading---------------------------------------------------------
load("../data/bibw2992.RData")
MutationMatrix <- bibw2992
Samples <- MutationMatrix$Cell.lines
IC50s <- MutationMatrix$BIBW2992
MutationMatrix <- MutationMatrix[, -2:-1]
Features <- colnames(MutationMatrix)
rownames(MutationMatrix) <- Samples

## ----Configuring Parameters----------------------------------------------
## Create binary input, output, and weight vector
#binary input
X <- MutationMatrix

N <- nrow(X)
P <- ncol(X)

#binarization threshold th
th <- 0.063218
Y <- as.double(IC50s < th)
W <- abs(IC50s - th)

#class weights
FPW <- 1
FPN <- 1

#normalize weights
W[Y == 1] <- FPW * W[Y == 1] / sum(W[Y == 1])
W[Y != 1] <- -(FPN * W[Y != 1] / sum(W[Y != 1]))

## Logic model complexity
K <- 2
M <- 1

## ----Cplex Options-------------------------------------------------------
param <- rbind(list('tilim', 60000, 'MaxTime'), #Maximum time for IP )in seconds)
               list('mipltolerances.integrality.Cur', 1e-5, 'Integrality'), #Integrality constraint; default = 1e-5 (see cplex.Param.mip.tolerances.integrality.Help)
               list('epgap', 1e-4, 'RelGap'), #Optimality gap tolerance; default = 1e-4 (0.01% of optimal solution, set to 0.05, 5% for early termination, approximate solution) (see cplex.Param.mip.tolerances.mipgap.Help)
               list('threads.Cur', 8, 'Threads'), #Number of threads to use (default = 0, automatic) (see cplex.Param.threads.Help)
               list('parallel.Cur', -1, 'ParallelMode'), #Parallel optimization mode, -1 = opportunistic 0 = automatic 1 = deterministic (see plex.Param.parallel.Help)
               list('solnpoolgap', 1e-1, 'Pool_relgap'), #Relative gap for suboptimal solutions in the pool; default 0.1 (10%)
               list('mip.pool.intensity.Cur', 1, 'Pool_intensity'), #Pool intensity; default 1 = mild: generate few solutions quickly (see cplex.Param.mip.pool.intensity.Help)
               list('mip.pool.replace.Cur', 2, 'Pool_replace'), #Pool replacement strategy; default 2 = replace least diverse solutions (see cplex.Param.mip.pool.replace.Help)
               list('mip.pool.capacity.Cur', 11, 'Pool_capacity'), #Pool capacity; default 11 = best + 10 (see cplex.Param.mip.pool.replace.Help)
               list('mip.limits.populate.Cur', 11, 'Pool_size'), #Number of solutions generated; default 11 = best + 10 (see cplex.Param.mip.limits.populate.Help)
               list('preind', 0, 'Presolver'),
               list('aggind', 1, 'Aggregator'))
               
param <- lapply(1:ncol(param), function(x){
  
  if (x==2) {
    return(as.numeric(unlist(param[, x])))
  }
  return(unlist(param[, x]))
  
})
param <- data.frame("V1" = param[[1]], "V2" = param[[2]], "V3" = param[[3]])

## ----Cplex Solver--------------------------------------------------------
## Cplex solver
sol <- lobico(X = X,
              Y = W,
              K = K,
              M = M,
              solve = 1,
              param = param)

## ----Checking Solution---------------------------------------------------
## Check solution
print('********************')
solMat <- .getsolution(sol, K, M, P)
print(solMat)
str <- .showformula(solMat, K, M, Features)
print('Inferred logical model')
print(str)

