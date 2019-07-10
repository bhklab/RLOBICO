# RLOBICO

## Windows Configuration

- [RLOBICO](#RLOBICO)
  - [Windows Configuration](#Windows-Configuration)
    - [Downloading CPLEX](#Downloading-CPLEX)
    - [Setting PATHS](#Setting-PATHS)
    - [Environmental Configuration Troubleshoot](#Environmental-Configuration-Troubleshoot)
  - [Linux Development Process](#Linux-Development-Process)
    - [CRAN Check 1](#CRAN-Check-1)
    - [CRAN Check 2](#CRAN-Check-2)
    - [CRAN Check 3: Checking in Terminal](#CRAN-Check-3-Checking-in-Terminal)
  - [Windows Development Process](#Windows-Development-Process)

### Downloading CPLEX
- We had difficulty accessing the CPLEX academic initiative directly from the IBM home page
- After much trial and error, we found this link: https://my15.digitalexperience.ibm.com/b73a5759-c6a6-4033-ab6b-d9d4f9a6d65b/dxsites/151914d1-03d2-48fe-97d9-d21166848e65/technology/data-science
  - This loads an alternative URL for the login page of the academic initiative
  - We were successful at logging in here with our PI's credentials and were able to download the program once logged in


### Setting PATHS
- In Windows paths are allowed to contain spaces; this causes issues with reading paths in R
- As a result the path needs to be in quotations
- If possible, we recommmend:
  - Installing CPLEX to `C:\` to avoid any problems which may be caused by spacing the path
  - Specify the absolute path of your directory, starting in the `C:\` drive
  - An example:
    - MacOS path to cplex/include: `-I/Applications/CPLEX_Studio128/cplex/include -I/Applications/CPLEX_Studio128/concert/include`
    - Windows path to cplex/include: `PKG_CPPFLAGS=-I"C:/IBM/ILOG/CPLEX_Studio129/cplex/include" -I"C:/IBM/ILOG/CPLEX_Studio129/concert/include"`
      - Ensure you set the correct version number for your CPLEX install in all your paths, as well as the `-lcplex12X0` call where X is your version number
      - See `Makevars.win` in the `src` folder for an example configuration on Windows
- It is worth noting that the location of library files on Windows is significantly different from MacOS and Linux
  - On MacOS and Linux library files for each respective CPLEX application are in `lib/x86-64_osx/static_pic`
  - On Windows there libraries are available instead in `lib/x64_windows_vs2017/stat_mda`
    - There is also an `mdd` folder with the `x64_windows_vs2017` folder with similar libraries; based on our research online `mda` is the most common choice in other R packages which implement CPLEX on Windows
    - Additionally, there is an alternative folder, `x64_windows_vs2017` which the same folders as the 2017 version
      - We selected to use the more recent release, again based on what we found in other packages from the R community


### Environmental Configuration Troubleshoot




## Linux Development Process
- Installed Ubuntu 18.04 to dual boot on my workstation
- Set up the development environment and installed CPLEX, R, RStudio
- Tested RLOBICO package: build and install are successful

### CRAN Check 1

**Errors**

  ```R
  * checking PDF version of manual without hyperrefs or index ... ERROR
  Re-running with no redirection of stdout/stderr.
  Hmm ... looks like a package
  You may want to clean up by 'rm -Rf /tmp/RtmplQB7yC/Rd2pdf15bd2ec634f0'
  ```
  - Ran recommended command
  - Added `--preclean` flag to `R CMD INSTALL`

  ```R
  * checking examples ... ERROR
  Running examples in ‘rlobico-Ex.R’ failed
  The error most likely occurred in:

  > base::assign(".ptime", proc.time(), pos = "CheckExEnv")
  > ### Name: rcpp_hello
  > ### Title: Hello, Rcpp!
  > ### Aliases: rcpp_hello
  > 
  > ### ** Examples
  > 
  > rcpp_hello()
  Error in rcpp_hello() : could not find function "rcpp_hello"
  Execution halted
  ```
  - Deleted depricated man file `man/rcpp_hello.RD`

Test

**Warnings**

  ```R
  * checking DESCRIPTION meta-information ... WARNING
  Non-standard license specification:
  None
  Standardizable: FALSE
  ```
  - Set `License: GPL-3` in `DESCRIPTION`

  ```R
  * checking Rd files ... WARNING
  prepare_Rd: CNF_ILP_weak_cpp.Rd:7-9: Dropping empty section \description
  prepare_Rd: CNF_ILP_weak_cpp.Rd:19-21: Dropping empty section \details
  prepare_Rd: CNF_ILP_weak_cpp.Rd:22-28: Dropping empty section \value
  prepare_Rd: CNF_ILP_weak_cpp.Rd:35-37: Dropping empty section \note
  prepare_Rd: CNF_ILP_weak_cpp.Rd:32-34: Dropping empty section \author
  prepare_Rd: CNF_ILP_weak_cpp.Rd:29-31: Dropping empty section \references
  prepare_Rd: CNF_ILP_weak_cpp.Rd:41-43: Dropping empty section \seealso
  checkRd: (5) CNF_ILP_weak_cpp.Rd:0-58: Must have a \description
  prepare_Rd: DNF_ILP_weak_cpp.Rd:7-9: Dropping empty section \description
  prepare_Rd: DNF_ILP_weak_cpp.Rd:19-21: Dropping empty section \details
  prepare_Rd: DNF_ILP_weak_cpp.Rd:22-28: Dropping empty section \value
  prepare_Rd: DNF_ILP_weak_cpp.Rd:35-37: Dropping empty section \note
  prepare_Rd: DNF_ILP_weak_cpp.Rd:32-34: Dropping empty section \author
  prepare_Rd: DNF_ILP_weak_cpp.Rd:29-31: Dropping empty section \references
  prepare_Rd: DNF_ILP_weak_cpp.Rd:41-43: Dropping empty section \seealso
  checkRd: (5) DNF_ILP_weak_cpp.Rd:0-58: Must have a \description
  prepare_Rd: solve_by_cplex_cpp.Rd:7-9: Dropping empty section \description
  prepare_Rd: solve_by_cplex_cpp.Rd:19-21: Dropping empty section \details
  prepare_Rd: solve_by_cplex_cpp.Rd:22-28: Dropping empty section \value
  prepare_Rd: solve_by_cplex_cpp.Rd:35-37: Dropping empty section \note
  prepare_Rd: solve_by_cplex_cpp.Rd:32-34: Dropping empty section \author
  prepare_Rd: solve_by_cplex_cpp.Rd:29-31: Dropping empty section \references
  prepare_Rd: solve_by_cplex_cpp.Rd:41-43: Dropping empty section \seealso
  checkRd: (5) solve_by_cplex_cpp.Rd:0-58: Must have a \description
  ```
  - Deleted all `man` files; will let `roxygen2` regenerate these

  ```R
  * checking for code/documentation mismatches ... WARNING
  Functions or methods with usage in documentation object 'rcpp_hello' but not in code:
    ‘rcpp_hello’

  Codoc mismatches from documentation object 'CNF_ILP_weak_cpp':
  CNF_ILP_weak_cpp
    Code: function(X, Y, W, K, M, lambda, sens, spec, addcons)
    Docs: function(x)
    Argument names in code not in docs:
      X Y W K M lambda sens spec addcons
    Argument names in docs not in code:
      x
    Mismatches in argument names:
      Position: 1 Code: X Docs: x

  Codoc mismatches from documentation object 'DNF_ILP_weak_cpp':
  DNF_ILP_weak_cpp
    Code: function(X, Y, W, K, M, lambda, sens, spec, addcons)
    Docs: function(x)
    Argument names in code not in docs:
      X Y W K M lambda sens spec addcons
    Argument names in docs not in code:
      x
    Mismatches in argument names:
      Position: 1 Code: X Docs: x

  Codoc mismatches from documentation object 'solve_by_cplex_cpp':
  solve_by_cplex_cpp
    Code: function(my_obj, my_cons, my_rhs, my_lb, my_ub)
    Docs: function(x)
    Argument names in code not in docs:
      my_obj my_cons my_rhs my_lb my_ub
    Argument names in docs not in code:
      x
    Mismatches in argument names:
      Position: 1 Code: my_obj Docs: x

  ```
  - Should be fixed by deleting old documentation


  ```R
  * checking Rd contents ... WARNING
  Auto-generated content requiring editing in Rd object 'CNF_ILP_weak_cpp':
    \keyword{~kwd1}
    \keyword{~kwd2}

  Auto-generated content requiring editing in Rd object 'DNF_ILP_weak_cpp':
    \keyword{~kwd1}
    \keyword{~kwd2}

  Auto-generated content requiring editing in Rd object 'solve_by_cplex_cpp':
    \keyword{~kwd1}
    \keyword{~kwd2}
  ```
  - Again related to `man` files

  ```R
  * checking compilation flags in Makevars ... WARNING
  Non-portable flags in variable 'PKG_CFLAGS':
    -g -O2
  Non-portable flags in variable 'PKG_CXXFLAGS':
    -g -O2 -std=c++11
  ```
  - Commented out these two arguments in `Makevars`

  ```R
  * checking PDF version of manual ... WARNING
  LaTeX errors when creating PDF version.
  This typically indicates Rd problems.
  ```
  - Installed pandoc

**Notes**


  ```R
  * checking CRAN incoming feasibility ... NOTE
Maintainer: ‘The package maintainer <li1033889482@gmail.com>’

New submission

Non-FOSS package license (None)

The Title field should be in title case. Current version is:
‘R-LOBICO: an R package for building logical models’
In title case that is:
‘R-LOBICO: An R Package for Building Logical Models’

The Description field should not start with the package name,
  'This package' or similar.
  ```
  - Renamed package in title case
  - Changed maintainer to Ben

  ```R
  * checking installed package size ... NOTE
  installed size is 39.8Mb
  sub-directories of 1Mb or more:
    libs  39.7Mb
  ```
  - Added `--resave-data` build flag
  - Didn't work, will need to at importFrom calls to decrease size


  ```R
  * checking top-level files ... NOTE
  Files ‘README.md’ or ‘NEWS.md’ cannot be checked without ‘pandoc’ being installed.
  Non-standard files/directories found at top level:
    ‘Makevars.win’ ‘devNotes.md’ ‘test’
  ```
  - Added these folders to `.rbuildignore`
  - Will move test code into `R` directory


  ```R
  * checking compiled code ... NOTE
  File ‘rlobico/libs/rlobico.so’:
    Found ‘_ZSt4cout’, possibly from ‘std::cout’ (C++)
      Objects: ‘CNF_ILP_weak.o’, ‘DNF_ILP_weak.o’

  Compiled code should not call entry points which might terminate R nor
  write to stdout/stderr instead of to the console, nor use Fortran I/O
  nor system RNGs.

  See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual.
  ```
  - Remove print statements from C code
  - Replaced `std::cout` with `Rcpp::Rcout` in above listed files.
  ```

### CRAN Check 2

**Errors**

None!

**Warnings**

```R
❯ checking dependencies in R code ... WARNING
  'library' or 'require' call not declared from: ‘Matrix’
  'library' or 'require' call to ‘Matrix’ in package code.
    Please use :: or requireNamespace() instead.
    See section 'Suggested packages' in the 'Writing R Extensions' manual.
```

```R
❯ checking for missing documentation entries ... WARNING
  Undocumented code objects:
    ‘CNF_CPLEX’ ‘CNF_CPLEX_weak_pos’ ‘CNF_ILP_weak’ ‘CNF_ILP_weak_cpp’
    ‘CNF_ILP_weak_pos’ ‘DNF_CPLEX’ ‘DNF_CPLEX_weak_pos’ ‘DNF_ILP_weak’
    ‘DNF_ILP_weak_cpp’ ‘DNF_ILP_weak_pos’ ‘bibw2992’ ‘lobico’
    ‘solve_by_cplex_cpp’
  Undocumented data sets:
    ‘bibw2992’
  All user-level objects in a package should have documentation entries.
  See chapter ‘Writing R documentation files’ in the ‘Writing R
  Extensions’ manual.

```


**Notes**

```R
❯ checking installed package size ... NOTE
    installed size is 39.9Mb
    sub-directories of 1Mb or more:
      libs  39.7Mb
```

```R
❯ checking top-level files ... NOTE
  Non-standard files/directories found at top level:
    ‘devNotes.md’ ‘rlobico_0.1.0.tar.gz’
```
- Will delete these for CRAN release

```R
  CNF_CPLEX: no visible global function definition for ‘c<-’
  CNF_CPLEX: no visible binding for global variable ‘P’
  CNF_CPLEX_weak_pos: no visible global function definition for ‘c<-’
  CNF_CPLEX_weak_pos: no visible binding for global variable ‘P’
  CNF_ILP_weak: no visible global function definition for ‘sparseMatrix’
  CNF_ILP_weak_pos: no visible global function definition for ‘c<-’
  CNF_ILP_weak_pos: no visible binding for global variable ‘P’
  CNF_ILP_weak_pos: no visible global function definition for ‘sparse’
  DNF_CPLEX: no visible global function definition for ‘c<-’
  DNF_CPLEX: no visible binding for global variable ‘P’
  DNF_CPLEX_weak_pos: no visible global function definition for ‘c<-’
  DNF_CPLEX_weak_pos: no visible binding for global variable ‘P’
  DNF_ILP_weak: no visible global function definition for ‘sparseMatrix’
  DNF_ILP_weak_pos: no visible global function definition for ‘c<-’
  DNF_ILP_weak_pos: no visible binding for global variable ‘P’
  DNF_ILP_weak_pos: no visible global function definition for ‘sparse’
  lobico: no visible binding for global variable ‘sense’
  lobico: no visible global function definition for ‘sparseMatrix’
  Undefined global functions or variables:
    P c<- sense sparse sparseMatrix
```

### CRAN Check 3: Checking in Terminal

**Warnings**

```R
* checking PDF version of manual ... WARNING
LaTeX errors when creating PDF version.
This typically indicates Rd problems.
```
- Going to delete man files are regenerate with Roxygen2

```R
* checking for code which exercises the package ... WARNING
No examples, no tests, no vignettes
```
- Writing examples and vignettes

**Notes**

```R
* checking installed package size ... NOTE
  installed size is 39.9Mb
  sub-directories of 1Mb or more:
    libs  39.7Mb
```
-Stack Overlflow indicates this is an acceptable note and common for packages compiled from C

```R
* checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Benjamin Haibe-Kains <benjamin.haibe-kain@utoronto.ca>’

New submission
```
- No need to correct his







## Windows Development Process

- RLOBICO is unable to install on the Windows platform
- A co-worker (Wail) has reported that his install works correctly on MacOS, and I assume it will also work on Linux
- Initially it took some time to figure out the paths for `PKG_CCPFLAGS`, `PKG_LDFLAGS` and `PKG_LIBS` as they are different from MacOS and Linux
- There are some issues with RTools 3.5 not being detected by RStudio, despite being accessible via terminal and console to compile packages
  - I have had to reinstall R, RTools and RStudio several times to ensure this error is not affecting the package
- When compiling on Windows, the process fails on `lobico.cpp` with the error: 
    ```R
    $ R CMD INSTALL --no-multiarch --with-keep.source --preclean rlobico_0.1.0.tar.gz
    * installing to library 'C:/R/R-3.6.0/library'
    * installing *source* package 'rlobico' ...
    ** package 'rlobico' successfully unpacked and MD5 sums checked
    ** using staged installation
    ** libs
    C:/Rtools/mingw_64/bin/g++  -I"C:/R/R-3.6.0/include" -DNDEBUG -I"C:/IBM/ILOG/CPLEX_Studio129/cplex
    /include" -I"C:/IBM/ILOG/CPLEX_Studio129/concert/include" -I"C:/R/R-3.6.0/library/Rcpp/include"
      -g -O2 -DIL_STD -std=c++0x   -O2 -Wall  -mtune=generic -c CNF_ILP_weak.cpp -o CNF_ILP_weak.o
    C:/Rtools/mingw_64/bin/g++  -I"C:/R/R-3.6.0/include" -DNDEBUG -I"C:/IBM/ILOG/CPLEX_Studio129/cplex
    /include" -I"C:/IBM/ILOG/CPLEX_Studio129/concert/include" -I"C:/R/R-3.6.0/library/Rcpp/include"
      -g -O2 -DIL_STD -std=c++0x   -O2 -Wall  -mtune=generic -c DNF_ILP_weak.cpp -o DNF_ILP_weak.o
    C:/Rtools/mingw_64/bin/g++  -I"C:/R/R-3.6.0/include" -DNDEBUG -I"C:/IBM/ILOG/CPLEX_Studio129/cplex
    /include" -I"C:/IBM/ILOG/CPLEX_Studio129/concert/include" -I"C:/R/R-3.6.0/library/Rcpp/include"
      -g -O2 -DIL_STD -std=c++0x   -O2 -Wall  -mtune=generic -c RcppExports.cpp -o RcppExports.o
    C:/Rtools/mingw_64/bin/g++  -I"C:/R/R-3.6.0/include" -DNDEBUG -I"C:/IBM/ILOG/CPLEX_Studio129/cplex
    /include" -I"C:/IBM/ILOG/CPLEX_Studio129/concert/include" -I"C:/R/R-3.6.0/library/Rcpp/include"
      -g -O2 -DIL_STD -std=c++0x   -O2 -Wall  -mtune=generic -c cpp_lobico.cpp -o cpp_lobico.o
    In file included from C:/IBM/ILOG/CPLEX_Studio129/concert/include/ilconcert/iloenv.h:21:0,
                     from C:/IBM/ILOG/CPLEX_Studio129/concert/include/ilconcert/iloalg.h:21,
                     from C:/IBM/ILOG/CPLEX_Studio129/concert/include/ilconcert/ilomodel.h:21,
                     from C:/IBM/ILOG/CPLEX_Studio129/cplex/include/ilcplex/ilocplex.h:27,
                     from cpp_lobico.cpp:8:
    C:/IBM/ILOG/CPLEX_Studio129/concert/include/ilconcert/ilosys.h:262:21: fatal error: generic.h: No
    such file or directory
     #include "generic.h"
                         ^
    compilation terminated.
    make: *** [C:/R/R-3.6.0/etc/x64/Makeconf:215: cpp_lobico.o] Error 1
    ERROR: compilation failed for package 'rlobico'
    * removing 'C:/R/R-3.6.0/library/rlobico'
    ```

- The offending block of code is from `ilosys.h` in `concert/include/iloconcert`; it reads are follows:
  
    ```R
    #if !(defined(name2))
    # if defined(ILO_MSVC) || defined(ILO_LINUX) || defined(ILO_APPLE) || defined(ILO_HP11)
    #  undef name2
    #  define name2(a,b)      _name2_aux(a,b)
    #  define _name2_aux(a,b)      a##b
    # else
    #include "generic.h"
    # endif
    #endif
    ```

- I attempted a work around by copying the function definition in the if condition into the else condition
  - This results in a number of different errors in other `.h` files; I assumed this means the code change broke the program
- Based on research online the `generic.h` error is caused by use of a depricated make function in the g++ compiler
- I have attempted to change the compiler used by RTools using:
  - `PKG_CC`,`PKG_CXX` and `PKG_CXX11` specifying path to alternative compiler in `Makevars.win` of package `src` folder
  - `CC`,`CXX` and `CXX11` specifying path to alternative compiler in `Makevars.win` of package `src` folder\
  - `CC`,`CXX` and `CXX11` specifying path to alternative compiler in `Makevars.win` of `$HOME/.R` folder
    - These are loaded as environmental variables into the terminal shell of RStudio
    - Can see the using `R CMD config --all` or `R CMD config <var_name>`
  - Replacing `g++.exe` in `C:\RTools\mingw_64\` with a symlink to other compilers, see below

- I put together a hack (thanks Petr) where I tricked RTools into calling the Microsoft Visual Studio compiler with a symlink, but it turns out this is incompatible with Rcpp:
    
       "2.9 Can I use Rcpp with Visual Studio ?
        Not a chance.
        And that is not because we are meanies but because R and 
        Visual Studio simply do not get along. As Rcpp is all about
        extending R with C++ interfaces, we are bound by the 
        available toolchain. And R simply does not compile with Visual
        Studio. Go complain to its vendor if you are still upset."
    - See [Rcpp-FAQ](https://mran.microsoft.com/snapshot/2014-11-17/web/packages/Rcpp/vignettes/Rcpp-FAQ.pdf)

- I have also tried using CPLEX 12.8 instead of 12.9, this made no difference to the error messages

- From the Rcpp documentation it seems that RTools only provides support for c++0x, will try build using this command
  - Didn't work
- Currently looking for another compiler to test this with: best option would be `icc` from Intel, but this is proprietary
  - Trying `clang++` for now

- I am also currently testing defining `generic.h` in `C:/R/R-3.6.0/include`

- I will attempt to configure one of `cplexAPI` or `Rcplex` packages on my R install
  - Even if this works we still cannot use `concert`, just `cplex`
  - Are there alternatives to `concert` for optimization?


