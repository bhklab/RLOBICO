import numpy as np
#import pandas as pd
#import sys
import cplex
#from cplex.exceptions import CplexError
#from numba import jit


'''
def populate_by_row(prob, obj, cons, rhs, lb, ub, sense):

    prob.objective.set_sense(prob.objective.sense.minimize)

    # Initialize the variables in cplex model
    prob.variables.add(obj = obj, ub = ub, lb = lb)
    n_eqs = len(rhs)
    n_vars = len(lb)
    var_types = []

    # Set the variables type
    for i in range(n_vars):
        var_types.append((i, prob.variables.type.integer))
    prob.variables.set_types(var_types)

    # Initialize the constraint matrix (sparse) in cplex model
    # The input constraint matrix is full matrix
    cons_sparse = []
    for i in range(n_eqs):
        idxs = np.nonzero(cons[i])
        cons_sparse.append(cplex.SparsePair(ind = idxs[0].tolist(), val = np.squeeze(cons[i, idxs], axis=0)))

    # Fit the cplex model
    prob.linear_constraints.add(lin_expr = cons_sparse, senses = sense, rhs = rhs)
    print("constraints in ")
'''
#@jit()
def solve_by_cplex(obj, cons, rhs, lb, ub, sense):

    obj = list(map(float, obj))

    cons_i = np.array(cons['i'])
    cons_j = np.array(cons['j'])
    cons_x = np.array(cons['x'])

    #cons = np.array(cons)
    rhs = list(map(float, rhs))
    lb = list(map(float, lb))
    ub = list(map(float, ub))
    #sense = np.repeat("L", len(rhs))

    my_prob = cplex.Cplex()
    #handle = populate_by_row(my_prob, obj, cons, rhs, lb, ub, sense)
    # Fit the populate_by_row function
    my_prob.objective.set_sense(my_prob.objective.sense.minimize)
    my_prob.variables.add(obj = obj, ub = ub, lb = lb)

    # Set the variables type
    '''
    var_types = []
    for i in range(len(lb)):
        var_types.append((i, my_prob.variables.type.integer))
    my_prob.variables.set_types(var_types)
    '''

    my_prob.variables.set_types(list(enumerate([my_prob.variables.type.integer] * len(lb), 0)))

    '''
    # Initialize the constraint matrix (sparse) in cplex model
    # The input constraint matrix is full matrix
    cons_sparse = []
    for i in range(len(rhs)):
        idxs = np.nonzero(cons[i])
        cons_sparse.append(cplex.SparsePair(ind = idxs[0].tolist(), val = np.squeeze(cons[i, idxs], axis=0)))
        # Initialize the constraint matrix (sparse pairs) in cplex model
        # However, this time we input the index/value pairs of sparse matrix
        # Hint: Could try not using the cplex.SparsePair
    '''
    #cons_sparse = []
    #m = np.unique(cons_i)
    '''
    for i in np.nditer(np.unique(cons_i)):
        idx = np.where(cons_i == i)[0]
        cons_sparse.append([(cons_j[idx] - 1).tolist(), cons_x[idx]])
        #cons_sparse.append(cplex.SparsePair(ind = (cons_j[idx] - 1).tolist(), val = cons_x[idx]))
    '''
    def yielder():
        for i in np.nditer(np.unique(cons_i)):
            idx = np.where(cons_i == i)[0]
            yield [(cons_j[idx] - 1).tolist(), cons_x[idx]]

    # Fit the cplex model
    my_prob.linear_constraints.add(lin_expr = list(yielder()), senses = sense, rhs = rhs)

    # Set the parmeters
    # Reduce the unnecessary threads used for MIP solving
    my_prob.parameters.threads.set(1)
    my_prob.parameters.preprocessing.dual.set(1)
    #my_prob.parameters.preprocessing.repeatpresolve.set(0)
    # Emphasis on feasibility instead of optimality, speed up the processing of the root node
    my_prob.parameters.emphasis.mip.set(1)
    # Skip any potential new solution that is not at least 1% better than the incumbent solution
    my_prob.parameters.mip.tolerances.relobjdifference.set(0.01)
    my_prob.solve()


    print('--------------------------------------------------')
    # solution.get_status() returns an integer code
    print("Solution status = " , my_prob.solution.get_status(), ":")
    # the following line prints the corresponding string
    print(my_prob.solution.status[my_prob.solution.get_status()])
    x = my_prob.solution.get_values()
    
    return(x)
