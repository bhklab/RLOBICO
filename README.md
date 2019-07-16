# RLOBICO

The logical models implemented in this package are based on the work of Knijnenburg *et al.* in:

[Knijnenburg et al, Logic models to predict continuous outputs based on binary inputs with an application to personalized cancer therapy, Sci Rep 2016](https://www.nature.com/articles/srep36812)

## System Requirements

1. This package is currently unsuported on Windows operating systems. It 
    has been successfully tested on Ubuntu 18.04 and MacOS Mojave, but we 
    expect other versions and distributions to be compatible.

2. C++11 is required to run included C/C++ functions. The package was 
    developed and tested using GNU's g++ compiler.

3. Rcpp is required to compile the C functions for use in R. Please
    ensure you have the latest version if you encounter installation
    issues with this package.

4. IBM ILOG CPLEX is required to solve optimization problems in logical models built 
    with this package. We have tested this package with IBM ILOG CPLEX 12.9; if you 
    have install issues please update CPLEX. IBM ILOG CPLEX is free under IBM's academic 
    initiative program for students and academic researchers. It can be downloaded 
    [here](https://my15.digitalexperience.ibm.com/b73a5759-c6a6-4033-ab6b-d9d4f9a6d65b/dxsites/151914d1-03d2-48fe-97d9-d21166848e65/technology/data-science) with a valid university associated email.

## Installation

1. Currently this package is only available on Unix and MacOS due to compatability
issues between IBM ILOG CPLEX and the Windows RTools compiler. We are currently 
trouble-shooting this issue and will update the README if any progress is made.

2. Please install the IBM ILOG CPLEX Optimization Studio (v>=12.9.0). The 
academic version is highly recommended, large size problems 
(>1,000 variables, >1,000 equations) will not be solved under the community 
version. The exception "Bad promotional version, problem size exceeds limit" 
will be raised.

3. The included configure script should be sufficient to locate your IBM ILOG
CPLEX installation directory and create the `src/Makevars` file for your
installation. If this process is unsuccessful we recommend moving the configure
script out of the RLOBICO directory and manually creating a Makevars file. We have
included `examples.Makevars` with the path and flags for the default installation 
locations on Ubuntu and MacOS. If these do not work you will need find the 
appropriate directories and set the package paths in Makevars accordingly.

4. This package can be installed from GitHub with 
`devtools::install_github("bhklab/RLOBICO")`. We are also
in the process of submitting to CRAN, after which the package will be available 
using the standard `install.packages` function.

## Example Data

The BIBW2992 dataset is included in this package to power our examples and vignettes.
