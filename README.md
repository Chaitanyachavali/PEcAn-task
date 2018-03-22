# Technical task from PEcAN for GSOC2018

## Steps to run the application
* Prerequisites 
  * Install R. You can get more info from [here](https://cran.r-project.org/doc/manuals/r-release/R-admin.html)
  * Install Rshiny. You can get more info from [here](https://shiny.rstudio.com/)
  * Install Plotly. You can get more info from [here](https://plot.ly/)
  * Get data from [Kaggle](https://www.kaggle.com/berkeleyearth/climate-change-earth-surface-temperature-data)
* Clone the repository by executing `git clone https://github.com/Chaitanyachavali/PEcAn.git`
* Create a new folder named `data` in cloned respository. You can do this in terminal by executing `mkdir path_to_repo/PEcAN/data`
* Copy all files from downloaded zip to data folder. You can do this in terminal by executing `cp -r path_to_downloded_zip/. path_to_repo/PEcAN/data/`
* Run with Rstudio
  * Open Rstudio and navigate to `path_to_repo/PEcAN`. You can do this in R Console by executing `setwd(path_to_repo/PEcAN)`.
  * open `main.R` and Run App. You can do this in R console by executing `runApp('main.R')`
* Run without Rstudio
  * Navigate to `path_to_repo/PEcAN`. You can do this in terminal by executing `cd path_to_repo/PEcAN`
  * Start the application from terminal by executing `R -e "shiny::runApp('main.R')"`
  * Once it starts you can see a url in the end which will look some thisn like this `http://127.0.0.1:XXXX`.
  * Copy the url and open it in a web browser.
  
## Info about files
* `main.R` is a shiny application which satisfies all minimum requirements mentioned in the task. Features covered in `main.R` are listed below
  * A line plot of temperate by country, selecting the country from a drop-down menu [Tab 1]
  * A bivariate scatter plot of temperatures for two different countries, selected from a drop-down menu by the user [Tab 2]
  * A bar chart of average temperature by country, averaged across the entire time series [Tab 3]
  * Ability to zoom in/out of the plot
  * More generally, ability to interact directly with the plot with a mouse 
  * Visualization technologies used [Plotly](https://plot.ly/)