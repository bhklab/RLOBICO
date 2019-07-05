# RLOBICO

## Windows Configuration

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



### Development Process So Far

- RLOBICO is unable to install on the Windows platform
- A co-worker (Wail) has reported that his install works correctly on MacOS, and I assume it will also work on Linux
- Initially it took some time to figure out the paths for `PKG_CCPFLAGS`, `PKG_LDFLAGS` and `PKG_LIBS` as they are different from MacOS and Linux
- There are some issues with RTools 3.5 not being detected by RStudio, despite being accessible via terminal and console to compile packages
  - I have had to reinstall R, RTools and RStudio several times to ensure this error is not affecting the package
- When compiling on Windows, the process fails on `lobico.cpp` with the error: 
    ```R

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


- I put together a hack (thanks Petr) where I tricked RTools into calling the Microsoft Visual Studio compiler with a symlink, but it turns out this is incompatible with Rcpp:
    
       "2.9 Can I use Rcpp with Visual Studio ?
        Not a chance.
        And that is not because we are meanies but because R and 
        Visual Studio simply do not get along. As Rcpp is all about
        extending R with C++ interfaces, we are bound by the 
        available toolchain. And R simply does not compile with Visual
        Studio. Go complain to its vendor if you are still upset."
    - See [Rcpp-FAQ](https://mran.microsoft.com/snapshot/2014-11-17/web/packages/Rcpp/vignettes/Rcpp-FAQ.pdf)

