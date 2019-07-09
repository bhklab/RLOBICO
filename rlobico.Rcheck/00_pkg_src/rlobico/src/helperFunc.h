#ifndef HELPERFUNC_H
#define HELPERFUNC_H
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <numeric>
#include <string.h>
#include <algorithm>
#include <Rcpp.h>


using namespace Rcpp;

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins(cpp11)]]

IntegerVector my_seq(int start, int end, int step = 1);
IntegerVector my_which(NumericVector x, int target);
NumericVector neg_convert(NumericVector x);
void matrix_update_scalar(NumericMatrix A, IntegerVector idx, int val);
void matrix_update_vec(NumericMatrix A, IntegerVector idx, IntegerVector vals);
NumericVector extract_row(DataFrame X, int nrow);

IntegerVector my_which_1(SEXP my_x, int target, int start);

#endif
