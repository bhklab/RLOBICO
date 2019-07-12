# RLOBICO

[Knijnenburg et al, Logic models to predict continuous outputs based on binary inputs with an application to personalized cancer therapy, Sci Rep 2016](https://www.nature.com/articles/srep36812)

## Installation

1. Currently this package is only available on Unix and MacOS due to compatability
issues between IBM ILOG CPLEX and the Windows RTools compiler. We are currently 
trouble-shooting this issue and will update the README if any progress is made.

2. Please install the IBM ILOG CPLEX Optimization Studio (v>=12.8.0). The 
academic version is highly recommended, large size problems 
(>1,000 variables, >1,000 equations) will not be solved under the community 
version. The exception "Bad promotional version, problem size exceeds limit" 
will be raised.

3. The included configure script should be sufficient to locate your IBM ILOG
CPLEX installation directory and create the `src/Makevars` file for your
installation. If this process is unsuccessful we recommend deleting the configure
script and manually creating a Makevars file. We have included `examples.Makevars`
with the path and flags for the default installation locations on Ubuntu and 
MacOS. If these do not work you will need find the appropriate directories and 
set the package flags accordingly.

4. This package can be installed from GitHub with 
`devtools::install_github("bhklab/RLOBICO", ref="RLOBICO_CRAN")`. We are also
in the process of submitting to CRAN, after which the package will be available 
using the standard `install.packages` function.

## Example Data

The BIBW2992 dataset is included in this package to power our examples and vignettes.

   
   
   
