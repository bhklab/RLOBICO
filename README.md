# RLOBICO

[Knijnenburg et al, Logic models to predict continuous outputs based on binary inputs with an application to personalized cancer therapy, Sci Rep 2016](https://www.nature.com/articles/srep36812)

## Installation

1. Please install the IBM ILOG CPLEX Optimization Studio (v>=12.8.0). The academic version is highly recommended, large size problems (>1,000 variables, >1,000 equations) will not be solved under the community version. The exception "Bad promotional version, problem size exceeds limit" will be raised.

2. Please modify the compiler and linker option to the paths of CPLEX libraries.
   
   For Linux users, in src/Makevars:
   ```
   PKG_CPPFLAGS = -I/path/to/CPLEX/cplex/include -I/path/to/CPLEX/concert/include
   PKG_LDFLAGS = -L/path/to/CPLEX/cplex/lib/x86-64_linux/static_pic -L/path/to/CPLEX/concert/lib/x86-64_linux/static_pic
   PKG_LIBS = -L/path/to/CPLEX/cplex/lib/x86-64_linux/static_pic -L/path/to/CPLEX/concert/lib/x86-64_linux/static_pic -lilocplex -lconcert -lcplex -lm -lpthread
   ```
   
   For Mac users, in src/Makevars:
   ```
   PKG_CPPFLAGS = -I/path/to/CPLEX/cplex/include -I/path/to/CPLEX/concert/include
   PKG_LDFLAGS = -L/path/to/CPLEX/cplex/lib/x86-64_osx/static_pic -L/path/to/CPLEX/concert/lib/x86-64_osx/static_pic
   PKG_LIBS = -L/path/to/CPLEX/cplex/lib/x86-64_osx/static_pic -L/path/to/CPLEX/concert/lib/x86-64_osx/static_pic -lilocplex -lconcert -lcplex -lm -lpthread
   ```
   
   For Windows users, please change the src/Makevars to src/Makevars.win, the modification of compiler and linker option is similar to the Mac or Linux.
   
3. The command below is recommended to build and install the package.
   ```
   R CMD INSTALL --preclean --no-multiarch --with-keep.source rlobico
   ```


   
   
   
