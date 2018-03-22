# Technical task from PEcAN for GSOC2018

## Steps to run the application
* Prerequisite: `Install R`. You can get more info from [here](https://cran.r-project.org/doc/manuals/r-release/R-admin.html) 
* Clone the repository by executing `git clone https://github.com/Chaitanyachavali/PEcAn.git`
* Run with Rstudio
  * Open Rstudio and navigate to `path_to_repo/PEcAN`. You can do this in R Console by executing `setwd(path_to_repo/PEcAN)`.
  * open `main.R` and Run App. You can do this in R console by executing `runApp('main.R')`
* Run without Rstudio
  * Navigate to `path_to_repo/PEcAN`. You can do this in terminal by executing `cd path_to_repo/PEcAN`
  * Start the application from terminal by executing `R -e "shiny::runApp('main.R')"`
  * Once it starts you can see a url in the end which will look some thisn like this `http://127.0.0.1:XXXX`.
  * Copy the url and open it in a web browser.