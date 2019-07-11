#' Lobico help function
#'
#' A wrapper for implementing C functions for calculating logical models
#' 
#' @examples 
#' test <- (2 + 2)
#' test
#' 
#' @param X An N x P binary matrix with N samples characterized by P binary features
#' @param Y An N x 1 binary vector, which is the binarized version of the continuous output variable
#' @param W An N x 1 continuous vector with weights for each of the N samples
#' @param K The number of disjunctive terms
#' @param M The maximum number of selected features per disjunctive term
#' @param lambda The regularizer of penalty for model complexity
#' @param sens The constraints on minimum sensitivity 
#' @param spec The constraints on minimum specificity
#' @param addcons Some additional constraints 
#' @param weak The parameter about whether to formulate weaker logic model
#' @param pos The parameter about whether to return quick and dirty solutions to disallow negations, i.e. only positive
#' 
#' @import Matrix Rcpp
#' @useDynLib rlobico _rlobico_CNF_ILP_weak_cpp _rlobico_DNF_ILP_weak_cpp _rlobico_solve_by_cplex_cpp
#'
#' @return 
#'
#' @export
#'
lobico <- function(X, Y, K, M, spec, sens, lambda, weak, pos, addcons) {
  
  ##Set undefined input arguments to default settings
  if (missing(spec) || is.na(spec) || !is.numeric(spec)) {spec <- 0}
  if (missing(sens) || is.na(sens) || !is.numeric(sens)) {sens <- 0}
  if (missing(lambda) || is.na(lambda) || !is.numeric(lambda)) {lambda <- 0}
  if (missing(weak) || is.na(weak) || !is.numeric(weak)) {weak <- 1}
  if (missing(pos) || is.na(pos) || !is.numeric(pos)) {pos <- 0}
  if (missing(addcons) || is.na(addcons) || !is.numeric(addcons)) {addcons <- matrix(nrow = 0, ncol = 2)}
  
  ## Formulate problem
  if (K <= M) {
    if (pos == TRUE) {
      CPLEXStuff <- DNF_ILP_weak_pos(X, as.double(Y > 0), abs(Y), K, M, lambda, sens, spec, addcons)
    } else {
      if (weak == TRUE) {
        #CPLEXStuff <- DNF_ILP_weak(X, as.double(Y > 0), abs(Y), K, M, lambda, sens, spec, addcons)
        #sourceCpp("DNF_ILP_weak.cpp")
        CPLEXStuff <- DNF_ILP_weak_cpp(X, as.double(Y > 0), abs(Y), K, M, lambda, sens, spec, addcons)
      } else {
        #list(f, Aineq, bineq, lb, ub, ctype)
        CPLEXStuff <- DNF_CPLEX(X, as.double(Y > 0), abs(Y), K, M, lambda, sens, spec, addcons)
      }
    }
  } else {
    if (pos == TRUE) {
      CPLEXStuff <- CNF_ILP_weak_pos(X, as.double(Y > 0), abs(Y), M, K, lambda, sens, spec, addcons)
    } else {
      if (weak == TRUE) {
        #CPLEXStuff <- CNF_ILP_weak(X, as.double(Y > 0), abs(Y), M, K, lambda, sens, spec, addcons)
        #install.packages("Rcpp", repos = "https://cran.r-project.org")
        #sourceCpp("CNF_ILP_weak.cpp")
        CPLEXStuff <- CNF_ILP_weak_cpp(X, as.double(Y > 0), abs(Y), M, K, lambda, sens, spec, addcons)
      } else {
        CPLEXStuff <- CNF_CPLEX(X, as.double(Y > 0), abs(Y), M, K, lambda, sens, spec, addcons)
      }
    }
  }
  
  # Need converted to be the numpy arrays inside the python script
  my_cons <- Matrix::sparseMatrix(i = as.vector(CPLEXStuff$cons_I),
                          j = as.vector(CPLEXStuff$cons_J),
                          x = as.vector(CPLEXStuff$cons_Q),
                          dims = CPLEXStuff$dims)

  my_cons <- summary(my_cons)
  my_obj <- CPLEXStuff$optfun
  my_rhs <- CPLEXStuff$consub
  my_lb <- CPLEXStuff$lb
  my_ub <- CPLEXStuff$ub
  my_sense <- rep('L', length(my_rhs))

  # my_obj <- CPLEXStuff[[1]]
  # my_cons <- summary(CPLEXStuff[[2]])
  # my_rhs <- CPLEXStuff[[3]]
  # my_lb <- CPLEXStuff[[4]]
  # my_ub <- CPLEXStuff[[5]]
  # my_sense <- rep('L', length(my_rhs))
  
  my_cons <- my_cons[order(my_cons$i),]
  #write.csv(my_cons, file = 'my_cons.csv')

  # Source the python_lobico.py script here, and call the functions

  #install.packages("reticulate", repos = "https://cran.r-project.org")
  
  # library(reticulate)
  # use_python("/anaconda3/bin/python")
  # source_python('p_lobico.py')
  # solution <- solve_by_cplex(my_obj, my_cons, my_rhs, my_lb, my_ub, my_sense)
  
  #install.packages('rcppCplex')
  #library(rcppCplex)

  solution <- solve_by_cplex_cpp(my_obj, my_cons, my_rhs, my_lb, my_ub)
  # solution <- function(my_obj, my_cons, my_rhs, my_lb, my_ub, my_sense) {
  #   .Call('solve_by_cplex_cpp', PACKAGE = 'rcppCplex', my_obj, my_cons, my_rhs, my_lb, my_ub, my_sense)
  # }

}