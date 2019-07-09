// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// CNF_ILP_weak_cpp
List CNF_ILP_weak_cpp(DataFrame X, NumericVector Y, NumericVector W, double K, double M, double lambda, double sens, double spec, NumericMatrix addcons);
RcppExport SEXP _rlobico_CNF_ILP_weak_cpp(SEXP XSEXP, SEXP YSEXP, SEXP WSEXP, SEXP KSEXP, SEXP MSEXP, SEXP lambdaSEXP, SEXP sensSEXP, SEXP specSEXP, SEXP addconsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< DataFrame >::type X(XSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type Y(YSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type W(WSEXP);
    Rcpp::traits::input_parameter< double >::type K(KSEXP);
    Rcpp::traits::input_parameter< double >::type M(MSEXP);
    Rcpp::traits::input_parameter< double >::type lambda(lambdaSEXP);
    Rcpp::traits::input_parameter< double >::type sens(sensSEXP);
    Rcpp::traits::input_parameter< double >::type spec(specSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type addcons(addconsSEXP);
    rcpp_result_gen = Rcpp::wrap(CNF_ILP_weak_cpp(X, Y, W, K, M, lambda, sens, spec, addcons));
    return rcpp_result_gen;
END_RCPP
}
// DNF_ILP_weak_cpp
List DNF_ILP_weak_cpp(DataFrame X, NumericVector Y, NumericVector W, double K, double M, double lambda, double sens, double spec, NumericMatrix addcons);
RcppExport SEXP _rlobico_DNF_ILP_weak_cpp(SEXP XSEXP, SEXP YSEXP, SEXP WSEXP, SEXP KSEXP, SEXP MSEXP, SEXP lambdaSEXP, SEXP sensSEXP, SEXP specSEXP, SEXP addconsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< DataFrame >::type X(XSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type Y(YSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type W(WSEXP);
    Rcpp::traits::input_parameter< double >::type K(KSEXP);
    Rcpp::traits::input_parameter< double >::type M(MSEXP);
    Rcpp::traits::input_parameter< double >::type lambda(lambdaSEXP);
    Rcpp::traits::input_parameter< double >::type sens(sensSEXP);
    Rcpp::traits::input_parameter< double >::type spec(specSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type addcons(addconsSEXP);
    rcpp_result_gen = Rcpp::wrap(DNF_ILP_weak_cpp(X, Y, W, K, M, lambda, sens, spec, addcons));
    return rcpp_result_gen;
END_RCPP
}
// solve_by_cplex_cpp
NumericVector solve_by_cplex_cpp(SEXP my_obj, SEXP my_cons, SEXP my_rhs, SEXP my_lb, SEXP my_ub);
RcppExport SEXP _rlobico_solve_by_cplex_cpp(SEXP my_objSEXP, SEXP my_consSEXP, SEXP my_rhsSEXP, SEXP my_lbSEXP, SEXP my_ubSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< SEXP >::type my_obj(my_objSEXP);
    Rcpp::traits::input_parameter< SEXP >::type my_cons(my_consSEXP);
    Rcpp::traits::input_parameter< SEXP >::type my_rhs(my_rhsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type my_lb(my_lbSEXP);
    Rcpp::traits::input_parameter< SEXP >::type my_ub(my_ubSEXP);
    rcpp_result_gen = Rcpp::wrap(solve_by_cplex_cpp(my_obj, my_cons, my_rhs, my_lb, my_ub));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_rlobico_CNF_ILP_weak_cpp", (DL_FUNC) &_rlobico_CNF_ILP_weak_cpp, 9},
    {"_rlobico_DNF_ILP_weak_cpp", (DL_FUNC) &_rlobico_DNF_ILP_weak_cpp, 9},
    {"_rlobico_solve_by_cplex_cpp", (DL_FUNC) &_rlobico_solve_by_cplex_cpp, 5},
    {NULL, NULL, 0}
};

RcppExport void R_init_rlobico(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}