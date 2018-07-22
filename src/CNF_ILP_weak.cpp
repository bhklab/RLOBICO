#include <Rcpp.h>
#include <iostream>
#include <numeric>
#include <stdio.h>
#include <stdlib.h>
#include "helperFunc.h"

using namespace Rcpp;

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins(cpp11)]]


// [[Rcpp::export]]
List CNF_ILP_weak_cpp(DataFrame X, NumericVector Y, NumericVector W, double K, double M, double lambda,
                  double sens, double spec, NumericMatrix addcons){

    int N = X.nrows();
    int P = X.length();

    /* Variables */
    // Selector variables S and S'
    /* Output of CNF OR gates and label for each sample (K+1)*N */
    int NoV = 2 * P * K + (K + 1) * N;

    /* Variables bound */
    NumericMatrix lb(NoV, 1);
    NumericMatrix ub(NoV, 1);
    std::fill(ub.begin(), ub.end(), 1);

    /* Variables type */
    std::string ctype(NoV, 'I');

    /* Optimizing function */
    std::cout << "Construction optimizing function..." << std::endl;
    NumericVector optfun(NoV);

    /* Error */

    IntegerVector Ip = my_which(Y, 1);
    IntegerVector In = my_which(Y, 0);
    IntegerVector Io = my_seq(2 * P * K + K * N + 1, 2 * P * K + (K + 1) * N);
    IntegerVector idxN = Io[In];
    IntegerVector idxP = Io[Ip];
    optfun[idxN - 1] = W[In];     // Error if mispredicting a 0
    optfun[idxP - 1] = neg_convert(W[Ip]);    // Error if mispredicting a 1


    /* Model Complexity penalty */
    if (M == -1) {
        optfun[my_seq(0, 2 * P * K - 1)] = lambda;
    }

    /* Constaints and their bounds */
    std::cout << "Constructing constaints..." << std::endl;
    // Number of constraints
    int NoC = P * K + N * K + N * K + N + N;
    if ((M > 0) && (M < P)){
        NoC += K;
    }
    if (((sens > 0) && (sens <= 1)) || ((sens < 0) && (sens >= -1))){
        NoC += 1;
    }
    if (((spec > 0) && (spec <= 1)) || ((spec < 0) && (spec >= -1))){
        NoC += 1;
    }

    NoC += K * addcons.nrow();

    // Number of nonzero elements
    int NoZ = 2 * P * K + N * K + K * N * P + N * K + K * N * P + N + N * K + N + N * K;

    if ((M > 0) && (M < P)) {
        NoZ += 2 * P * K;
    }
    if (((sens > 0) && (sens <= 1)) || ((sens < 0) && (sens >= -1))) {
        NoZ += Ip.size();
    }
    if (((spec > 0) && (spec <= 1)) || ((spec < 0) && (spec >= -1))) {
        NoZ += In.size();
    }

    if (addcons.nrow()){
        for (int c = 0; c < addcons.nrow(); c++) {
            continue;
            //Some problems here
            //NoZ += 2 * K * addcons(c, 1).size();
        }
    }


    /* Variables for sparse matrix */
    NumericMatrix I(NoZ, 1);
    NumericMatrix J(NoZ, 1);
    NumericMatrix Q(NoZ, 1);
    IntegerVector consub(NoC, 0);
    int conr = 0;  // Setting the constraint number
    int conz = 0;  // Setting the number of non-zero elements


    /* Constraint 1 OR between S and S' */
    IntegerVector p = my_seq(1, P);
    IntegerVector ix;
    for (int k = 1; k <= K; k++){
        ix = conz + p;
        matrix_update_vec(I, ix - 1, p + conr + (k - 1) * P);
        matrix_update_vec(J, ix - 1, p + (k - 1) * P);
        matrix_update_scalar(Q, ix - 1, 1);
        conz += P;
        ix = conz + p;
        matrix_update_vec(I, ix - 1, p + conr + (k - 1) * P);
        matrix_update_vec(J, ix - 1, p + P * K + (k - 1) * P);
        matrix_update_scalar(Q, ix - 1, 1);
        consub[conr + (k - 1) * P + p - 1] = 1;
        conz += P;
    }

    conr = P * K;
    conz = 2 * P * K;

    /* Constraint 2 OR for kth conjunctive term */
    IntegerVector k = my_seq(1, K);
    //ix = IntegerVector(k.size(), 0);
    for (int n = 1; n <= N; n++){
        NumericVector target = extract_row(X, n - 1);
        IntegerVector PosSet = my_which(target, 1) + 1;
        IntegerVector NegSet = my_which(target, 0) + 1;
        int LPS = PosSet.size();
        int LNS = NegSet.size();
        ix = conz + k;

        matrix_update_vec(I, ix - 1, conr + (k - 1) * N + n);
        matrix_update_vec(J, ix - 1, 2 * P * K + (k - 1) * N + n);
        matrix_update_scalar(Q, ix - 1, 1);
        conz += K;
        ix = conz + k;
        matrix_update_vec(I, ix - 1, conr + N * K + (k - 1) * N + n);
        matrix_update_vec(J, ix - 1, 2 * P * K + (k - 1) * N + n);
        matrix_update_scalar(Q, ix - 1, -P);
        conz += K;
        for (int kk = 1; kk <= K; kk++){
            IntegerVector ix_1 = my_seq(1, LPS) + conz;
            matrix_update_scalar(I, ix_1 - 1, conr + (kk - 1) * N + n);
            if (PosSet.size() > 0){
                matrix_update_vec(J, ix_1 - 1, (kk - 1) * P + PosSet);
            }
            matrix_update_scalar(Q, ix_1 - 1, -1);
            conz += LPS;
            ix_1 = my_seq(1, LNS) + conz;
            matrix_update_scalar(I, ix_1 - 1, conr + (kk - 1) * N + n);
            matrix_update_vec(J, ix_1 - 1, P * K + (kk - 1) * P + NegSet);
            matrix_update_scalar(Q, ix_1 - 1, -1);
            conz += LNS;
            ix_1 = my_seq(1, LPS) + conz;
            matrix_update_scalar(I, ix_1 - 1, conr + N * K + (kk - 1) * N + n);
            if (PosSet.size() > 0){
                matrix_update_vec(J, ix_1 - 1, (kk - 1) * P + PosSet);
            }
            matrix_update_scalar(Q, ix_1 - 1, 1);
            conz += LPS;
            ix_1 = my_seq(1, LNS) + conz;
            matrix_update_scalar(I, ix_1 - 1, conr + N * K + (kk - 1) * N + n);
            matrix_update_vec(J, ix_1 - 1, P * K + (kk - 1) * P + NegSet);
            matrix_update_scalar(Q, ix_1 - 1, 1);
            conz += LNS;
        }
        consub[conr + (k - 1) * N + n - 1] = 0;
        consub[conr + N * K + (k - 1) * N + n - 1] = 0;
    }

    conr = P * K + N * K + N * K;
    conz = 2 * P * K + N * K + K * N * P + N * K + K * N * P;

    /* Constraint 3 BIG AND between the K conjunctive terms */
    IntegerVector n = my_seq(1, N);
    ix = conz + n;
    matrix_update_vec(I, ix - 1, conr + n);
    matrix_update_vec(J, ix - 1, 2 * P * K + N * K + n);
    matrix_update_scalar(Q, ix - 1, -1);
    conz += N;
    ix = conz + n;
    matrix_update_vec(I, ix - 1, conr + N + n);
    matrix_update_vec(J, ix - 1, 2 * P * K + N * K + n);
    matrix_update_scalar(Q, ix - 1, K);
    conz += N;
    k = my_seq(1, K);
    for (int nn = 1; nn <= N; nn++){
        ix = conz + k;
        matrix_update_scalar(I, ix - 1, conr + nn);
        matrix_update_vec(J, ix - 1, 2 * P * K + my_seq(nn, N * K, N));
        matrix_update_scalar(Q, ix - 1, 1);
        conz += K;
        ix = conz + k;
        matrix_update_scalar(I, ix - 1, conr + N + nn);
        matrix_update_vec(J, ix - 1, 2 * P * K + my_seq(nn, N * K, N));
        matrix_update_scalar(Q, ix - 1, -1);
        conz += K;
    }
    consub[conr + n - 1] = K - 1;
    consub[conr + N + n - 1] = 0;
    conr = P * K + N * K + N * K + N + N;
    conz = 2 * P * K + N * K + K * N * P + N * K + K * N * P + N + N * K + N + N * K;

    /* Limit the number of terms per disjunct */
    if ((M > 0) && (M < P)) {
        p = my_seq(1, P);
        for (int k = 1; k <= K; k++){
            ix = p + conz;
            matrix_update_scalar(I, ix - 1, conr + k);
            matrix_update_vec(J, ix - 1, my_seq((k - 1) * P + 1, (k - 1) * P + P));
            matrix_update_scalar(Q, ix - 1, 1);
            conz += P;
            ix = conz + p;
            matrix_update_scalar(I, ix - 1, conr + k);
            matrix_update_vec(J, ix - 1, my_seq(P * K + (k - 1) * P + 1, P * K + (k - 1) * P + P));
            matrix_update_scalar(Q, ix - 1, 1);
            conz += P;
            consub[conr + k - 1] = M;
        }
        conr += K;
    }
    /* Sensitivity constraint */
    // if ((sens > 0) && (sens <= 1)) {
    //     // sum function? ????????????????????
    //     // Done
    //     int NoP = sum(Y == 1);
    //     ix = conz + my_seq(1, Ip.size());
    //     // I[ix - 1] = conr + 1;
    //     // J[ix - 1] = Io[Ip];
    //     // Q[ix - 1] = -1;
    //     matrix_update_scalar(I, ix - 1, conr + 1);
    //     matrix_update_vec(J, ix - 1, Io[Ip]);
    //     matrix_update_scalar(Q, ix - 1, -1);
    //     conz += Ip.size();
    //     consub[conr + 1 - 1] = -NoP * sens;
    //     conr += 1;
    // } else if ((sens < 0) && (sens >= -1)) { /* Continuous sensitivity constraint */
    //     sens = -sens;
    //     int NoP = sum(W[Ip]);
    //     ix = conz + my_seq(1, Ip.size());
    //     // I[ix - 1] = conr + 1;
    //     // J[ix - 1] = Io[Ip];
    //     // Q[ix - 1] = -W[Ip];
    //
    //     conz += Ip.size();
    //     consub[conr + 1 - 1] = -NoP * sens;
    //     conr += 1;
    // }
    //
    // /* Specificity constraint */
    // if ((spec > 0) && (spec <= 1)){
    //     NoN <- sum(Y == 0)
    //     ix = conz + my_seq(1, In.size());
    //     I[ix - 1] = conr + 1;
    //     J[ix - 1] = Io[In - 1];
    //     Q[ix - 1] = 1;
    //     conz += In.size();
    //     consub[conr + 1 - 1] = NoN * (1 - spec);
    //     conr += 1;
    // } else if ((spec < 0 ) && (spec >= -1)) {  /* Continuous specificity constraint */
    //     spec = -spec;
    //     NoN <- sum(W[In]);
    //     ix = conz + my_seq(1, In.size());
    //     I[ix - 1] = conr + 1;
    //     J[ix - 1] = Io[In - 1];
    //     Q[ix - 1] = 1;
    //     conz += In.size();
    //     consub[conr + 1 - 1] = NoN * (1 - spec);
    //     conr += 1;
    // }
    //
    // /* Additional constraints on allowed features */
    // if (addcons.nrow() > 0){
    //     for (int c = 1; c <= addcons.nrow(); c++){
    //         if (addcons[c - 1, 3 - 1] == 's'){
    //             for (k = 1; k <= K; k++){
    //                 ix = conz + my_seq(1, addcons[c - 1, 1 - 1].size());
    //                 I[ix - 1] = conr + k;
    //                 J[ix - 1] = (k - 1) * P + addcons[c - 1, 1 - 1];
    //                 Q[ix - 1] = 1;
    //                 conz += addcons[c - 1, 1 - 1].size();
    //                 ix = conz + my_seq(1, addcons[c - 1, 1 - 1].size());
    //                 I[ix - 1] = conr + k;
    //                 J[ix - 1] = P * K + (k - 1) * P + addcons[c - 1, 1 - 1];
    //                 Q[ix - 1] = 1;
    //                 conz += addcons[c - 1, 1 - 1].size();
    //                 consub[conr + k - 1] = addcons[c - 1, 2 - 1];
    //             }
    //             conr += K;
    //         } else if (addcons[c - 1, 3 - 1] == 'g'){
    //             for (k = 1; k <= K; k++){
    //                 ix = conz + my_seq(1, addcons[c - 1, 1 - 1].size());
    //                 I[ix - 1] = conr + k;
    //                 J[ix - 1] = (k - 1) * P + addcons[c - 1, 1 - 1];
    //                 Q[ix - 1] = -1;
    //                 conz += addcons[c - 1, 1 - 1].size();
    //                 ix = conz + my_seq(1, addcons[c - 1, 1 - 1].size());
    //                 I[ix - 1] = conr + k;
    //                 J[ix - 1] = P * K + (k - 1) * P + addcons[c - 1, 1 - 1];
    //                 Q[ix - 1] = -1;
    //                 conz += addcons[c - 1, 1 - 1].size();
    //                 consub[conr + k - 1] = -addcons[c - 1, 2 - 1];
    //             }
    //             conr += K;
    //         }
    //     }
    // }
    List output;
    output["optfun"] = optfun;
    output["consub"] = consub;
    output["lb"] = lb;
    output["ub"] = ub;
    output["ctype"] = ctype;
    output["cons_I"] = I;
    output["cons_J"] = J;
    output["cons_Q"] = Q;
    output["dims"] = IntegerVector::create(NoC, NoV);

    return output;
}
