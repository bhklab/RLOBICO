//#ifdef IL_STD
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <numeric>
#include <string.h>
#include <algorithm>
#include <ilcplex/ilocplex.h>
#include <Rcpp.h>
#include <chrono>
#include "helperFunc.h"

using namespace Rcpp;

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins(cpp11)]]


// [[Rcpp::export]]
NumericVector solve_by_cplex_cpp(SEXP my_obj, SEXP my_cons, SEXP my_rhs, SEXP my_lb, SEXP my_ub) {

    /* Arguments processing */

    NumericVector obj(my_obj), rhs(my_rhs), lb(my_lb), ub(my_ub);
    DataFrame cons(my_cons);

    IntegerVector cons_i = cons["i"];
    IntegerVector cons_j = cons["j"];
    IntegerVector cons_x = cons["x"];

    int varsNum = obj.size();

    IloEnv env;
    IloCplex cplex(env);
    IloModel model(env);
    IloNumVarArray vars(env, varsNum);
    IloNumArray coefs(env, varsNum);

    /* Set the option of IP solver */
    cplex.setParam(IloCplex::Threads, 1);
    // cplex.setParam(IloCplex::Param::Preprocessing::Reduce, 1);
    // cplex.setParam(IloCplex::Param::Emphasis::MIP, 1);
    // cplex.setParam(IloCplex::Param::MIP::Tolerances::RelObjDifference, 0.01);


    /* Variables*/

    int i = 0;
    for (; i < varsNum; i++) {
        vars[i] = IloNumVar(env, lb[i], ub[i], ILOINT);
        coefs[i] = obj[i];
    }

    /* Objective function */
    // Default sense is minimization
    IloObjective objective(env);
    objective.setLinearCoefs(vars, coefs);
    model.add(objective);

    /* Constraint Matrix */
    IntegerVector unique_cons_i = sort_unique(cons_i);
    IloRangeArray constraints(env, unique_cons_i.size());

    int start = 0;
    for (IntegerVector::iterator it = unique_cons_i.begin(); it != unique_cons_i.end(); it++) {
        // The value of iterator here means the row number of equations
        int idx = *it;
        IntegerVector idxs = my_which_1(cons_i, idx, start);
        IntegerVector varIdx = cons_j[idxs];
        IntegerVector varCoef = cons_x[idxs];
        start += idxs.size();

        // The mathematics expression of this row
        IloExpr xpr(env);
        for (i = 0; i < varIdx.size(); i++) {
            int num = varIdx[i];
            xpr += varCoef[i] * vars[num - 1];
        }

        // Using the lower and upper bounds to set the "less" operator
        constraints.add(IloRange(env, -IloInfinity, xpr, rhs[(idx - 1)]));
        xpr.end();

    }

    model.add(constraints);

    /* Extract the model to the CPLEX solver */

    cplex.extract(model);
    cplex.solve();

    /* Output the solution */
    env.out() << "Solution status = " << cplex.getStatus() << std::endl;

    IloNumArray new_vals(env);
    cplex.getValues(new_vals, vars);

    NumericVector x(new_vals.getSize());
    for (i = 0; i < new_vals.getSize(); i++) {
        x[i] = new_vals[i];
    }

    env.end();
    return x;
}

//#endif
