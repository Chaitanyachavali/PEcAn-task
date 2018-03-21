library(shiny)
library(plotly)

# Reading the file
raw_data = read.delim("data/GlobalLandTemperaturesByCountry.csv",sep=',')

# Missing values are greatest problem while visualization of data. So eliminating before going any further.
# Finding the total number of missing values
sum(is.na(raw_data))
# Removing all the missing values
countries_data = na.omit(raw_data)
# checking whether all missing values are been removed or been
sum(is.na(countries_data))

# We need to all column in the file as all the data will be accessed via column names
# Getting all column names from the given data.
colnames(countries_data)

# We need to create dropdown of countries. So we will first get all the countries from the data
countries=unique(countries_data$Country)

# Coming on to shiny UI
# Use a fluid Bootstrap layout
ui=fluidPage(    
  # Setting Page title
  titlePanel("Temperature Visualizations"),
  # Generate a row with a sidebar
  sidebarLayout(      
    # Define the sidebar with one input
    sidebarPanel(
      # Dropdown with all countries
      selectInput("tab1_countries", "Countries:", 
                  choices=countries),
      hr(),
      helpText("Please select a country from the dropdown.")
    ),
    # Create a space for the line plot
    mainPanel(
      plotlyOutput("plot_area")  
    )
    
  )
)

# Coming on to Shiny Backend
# Define a server for the Shiny app
server=function(input, output) {
  # Extracting selected country data from whole data
  extract_data = isolate(subset(countries_data,countries_data$Country==input$tab1_countries))
  # We only need two columns from it
  date = extract_data$dt
  avg_temperature = extract_data$AverageTemperature
  data_frame <- data.frame(date,avg_temperature)
  # Custom font to display neatly
  custom_font <- list(
    family = "Courier New, monospace",
    size = 18,
    color = "#7f7f7f"
  )
  x <- list(
    titlefont = custom_font,
    tickangle = 90
  )
  y <- list(
    title = "Average Temperature",
    titlefont = custom_font
  )
  # Filling the space with plot using plotly
  output$plot_area <- renderPlotly({
    plot_ly(data_frame, x = ~date, y = ~avg_temperature, type = 'scatter', mode = 'lines')%>%
      layout(title =input$tab1_countries, xaxis = x, yaxis = y, margin = 220)
  })
}

# Run Shin
shinyApp(ui = ui, server = server)