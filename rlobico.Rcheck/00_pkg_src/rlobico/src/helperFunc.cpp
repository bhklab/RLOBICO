#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <numeric>
#include <string.h>
#include <algorithm>
#include <Rcpp.h>
#include "helperFunc.h"

using namespace Rcpp;

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins(cpp11)]]

/* Helper Function */
/* The function my_seq works as seq function in R */
IntegerVector my_seq(int start, int end, int step) {
    if (step == 1) {
        IntegerVector y(abs(end - start) + 1);
        std::iota(y.begin(), y.end(), start);
        return y;
    } else {
        IntegerVector y;
        for (int i = start; i <= end; i = i + step) {
            y.push_back(i);
        }
        return y;
    }

}

/* The function my_which works as which function in R */
IntegerVector my_which(NumericVector x, int target) {
    IntegerVector idx;
    for (NumericVector::iterator it = x.begin(); it != x.end(); it++){
        if (*it == target) {
            idx.push_back(std::distance(x.begin(), it));
        }
    }
    return idx;
}

NumericVector neg_convert(NumericVector x) {
    NumericVector y;
    for (NumericVector::iterator it = x.begin(); it != x.end(); it++) {
        y.push_back(-1 * *it);
    }
    return y;
}

void matrix_update_scalar(NumericMatrix A, IntegerVector idx, int val) {
    NumericMatrix Acpp(A);
    //int nc = Acpp.ncol();
    for (IntegerVector::iterator it = idx.begin(); it != idx.end(); it++) {
        Acpp[*it] = val;
    }
}

void matrix_update_vec(NumericMatrix A, IntegerVector idx, IntegerVector vals){
    NumericMatrix Acpp(A);
    int len = idx.length();
    for (int i = 0; i < len; i++) {
        int m = idx[i];
        A[m] = vals[i];
    }
}

NumericVector extract_row(DataFrame X, int nrow) {
    NumericVector y;
    int ncols = X.size();
    for (int j = 0; j < ncols; j++) {
        y.push_back((as<std::vector<double> >(X[j]))[nrow]);
    }
    return y;
}

IntegerVector my_which_1(SEXP my_x, int target, int start) {
    IntegerVector x(my_x);
    std::vector<int> idxs;
    for (int i = start; i < x.size(); i++) {
        if (x[i] == target) {
            idxs.push_back(i);
        }
        else if (x[i] > target) {
            break;
        }
    }
    return wrap(idxs);
}
