## Initialize
#Init

## Create artificial dataset

#parameters
N <- 500
P <- 25
K <- 2
M <- 2
nX <- 0.01
nY <- 0.1

list(X, Y, W, SolMatT) <- makeartificialdataset(N, P, K, M, nX, nY)

## Cplex options
param <- rbind(list('timelimit.Cur', 60, 'MaxTime'), #Maximum time for IP )in seconds)
               list('mipltolerances.integrality.Cur', 1e-5, 'Integrality'), #Integrality constraint; default = 1e-5 (see cplex.Param.mip.tolerances.integrality.Help)
               list('mip.tolerancs.mipgap.Cur', 1e-4, 'RelGap'), #Optimality gap tolerance; default = 1e-4 (0.01% of optimal solution, set to 0.05, 5% for early termination, approximate solution) (see cplex.Param.mip.tolerances.mipgap.Help)
               list('threads.Cur', 8, 'Threads'), #Number of threads to use (default = 0, automatic) (see cplex.Param.threads.Help)
               list('parallel.Cur', -1, 'ParallelMode'), #Parallel optimization mode, -1 = opportunistic 0 = automatic 1 = deterministic (see plex.Param.parallel.Help)
               list('mip.pool.relgap.Cur', 1e-1, 'Pool_relgap'), #Relative gap for suboptimal solutions in the pool; default 0.1 (10%)
               list('mip.pool.intensity.Cur', 1, 'Pool_intensity'), #Pool intensity; default 1 = mild: generate few solutions quickly (see cplex.Param.mip.pool.intensity.Help)
               list('mip.pool.replace.Cur', 2, 'Pool_replace'), #Pool replacement strategy; default 2 = replace least diverse solutions (see cplex.Param.mip.pool.replace.Help)
               list('mip.pool.capacity.Cur', 11, 'Pool_capacity'), #Pool capacity; default 11 = best + 10 (see cplex.Param.mip.pool.replace.Help)
               list('mip.limits.populate.Cur', 11, 'Pool_size')) #Number of solutions generated; default 11 = best + 10 (see cplex.Param.mip.limits.populate.Help)


## Cplex solver
sol <- lobico(X, W, K, M, 1, param)

## Check solution
print('********************')

#inferred formula
x <- round(sol.Solution.x)
SolMat <- getsolution(x, K, M, P)
str <- showformula(SolMat, K, M)
print('Inferred logical model')
print(str)

#actual formula
str <- showformula(SolMatT, K, M)
print('Actual logic model')
print(str)

print('********************')