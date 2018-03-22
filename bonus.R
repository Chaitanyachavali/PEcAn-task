library(shiny)
library(plotly)

# Reading the file
raw_data <- read.delim("data/GlobalLandTemperaturesByCountry.csv", sep = ",")

# Missing values are greatest problem while visualization of data. So eliminating before going any further.
# Finding the total number of missing values
sum(is.na(raw_data))
# Removing all the missing values
countries_data <- na.omit(raw_data)
# checking whether all missing values are been removed or been
sum(is.na(countries_data))

# We need to all column in the file as all the data will be accessed via column names
# Getting all column names from the given data.
colnames(countries_data)

# We need to create dropdown of countries. So we will first get all the countries from the data
countries <- unique(countries_data$Country)

# Coming on to shiny UI
# Use a fluid Bootstrap layout
ui <- fluidPage(
  # Give the page a title
  titlePanel("Temperature Visualizations"),
  # Creating Tabs
  tabsetPanel(
    # Tab 1
    tabPanel(
      title = "By Country (Line Chart)",
      # Dropdown of countries
      sidebarLayout(
        sidebarPanel(
          selectInput("tab1_countries", "Countries:",
            choices = countries,
            selected = "India"
          ),
          hr(),
          helpText("Please select a country from the dropdown.")
        ),
        mainPanel(
          # Chart Area
          plotlyOutput("tab1_plot_area")
        )
      )
    ),
    # Tab 2
    tabPanel(
      title = "Two countries (Scatter Plot)",
      sidebarPanel(
        selectInput("tab2_countryA", "Countries A:",
          choices = countries,
          selected = "India"
        ),
        selectInput("tab2_countryB", "Countries B:",
          choices = countries,
          selected = "Africa"
        ),
        hr(),
        helpText("Please select two countries from the dropdown")
      ),
      mainPanel(
        plotlyOutput("tab2_plot_area")
      )
    ),
    # Tab 3
    tabPanel(
      title = "Average Temperature (Bar Chart)",
      sidebarLayout(
        sidebarPanel(
          selectInput("tab3_countries", "Countries:",
            choices = countries,
            selected = "India"
          ),
          hr(),
          helpText("Please select a country from the dropdown.")
        ),
        mainPanel(
          plotlyOutput("tab3_plot_area")
        )
      )
    )
  )
)


# Coming on to Shiny Backend
# Define a server for the Shiny app
server <- function(input, output) {
  # Tab 1 processings
  # Custom font to display neatly
  custom_font <- list(
    family = "Courier New, monospace",
    size = 18,
    color = "#7f7f7f"
  )
  x <- list(
    title = "Date",
    titlefont = custom_font,
    tickangle = 50
  )
  y <- list(
    title = "Temperature",
    titlefont = custom_font
  )
  x_bar <- list(
    title = "Count",
    titlefont = custom_font,
    tickangle = 90
  )
  # Filling the space with plot using plotly
  output$tab1_plot_area <- renderPlotly({
    # Extracting selected country data from whole data
    tab1_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab1_countries))
    # We only need two columns from it
    date <- tab1_extract_data$dt
    avg_temperature <- tab1_extract_data$AverageTemperature
    uncert_temperature <- tab1_extract_data$AverageTemperatureUncertainty
    data_frame <- data.frame(date, avg_temperature)
    data_frame_uncert <- data.frame(date, uncert_temperature)
    plot_ly(data_frame, x = ~ date, y = ~ avg_temperature, name = "Temperature", type = "scatter", mode = "lines") %>%
      add_trace(data_frame_uncert, x = ~ date, y = ~ uncert_temperature, name = "Temperature Uncertainty", type = "scatter", mode = "lines") %>%
      layout(title = input$tab1_countries, xaxis = x, yaxis = y, margin = 220)
  })

  # Tab 2 processings
  # Extract 2 countries data
  layout_title <- reactive({
    paste(input$tab2_countryA, input$tab2_countryB, sep = " and ")
  })
  output$tab2_plot_area <- renderPlotly({
    tab2_extract_data_countryA <- isolate(subset(countries_data, countries_data$Country == input$tab2_countryA))
    tab2_extract_data_countryB <- isolate(subset(countries_data, countries_data$Country == input$tab2_countryB))
    tab2_extract_data <- isolate(merge(tab2_extract_data_countryA, tab2_extract_data_countryB, all = TRUE))
    plot_ly(data.frame(tab2_extract_data_countryA$dt, tab2_extract_data_countryA$AverageTemperature), x = ~ tab2_extract_data_countryA$dt, y = ~ tab2_extract_data_countryA$AverageTemperature, name = reactive({
      paste(input$tab2_countryA, "Temperature", sep = " - ")
    })(), type = "scatter") %>%
      add_trace(data.frame(tab2_extract_data_countryB$dt, tab2_extract_data_countryB$AverageTemperature), x = ~ tab2_extract_data_countryB$dt, y = ~ tab2_extract_data_countryB$AverageTemperature, name = reactive({
        paste(input$tab2_countryB, "Temperature", sep = " - ")
      })(), type = "scatter") %>%
      add_trace(data.frame(tab2_extract_data_countryA$dt, tab2_extract_data_countryA$AverageTemperatureUncertainty), x = ~ tab2_extract_data_countryA$dt, y = ~ tab2_extract_data_countryA$AverageTemperatureUncertainty, name = reactive({
        paste(input$tab2_countryA, "Temperature Uncertainity", sep = " - ")
      })(), type = "scatter") %>%
      add_trace(data.frame(tab2_extract_data_countryB$dt, tab2_extract_data_countryB$AverageTemperatureUncertainty), x = ~ tab2_extract_data_countryB$dt, y = ~ tab2_extract_data_countryB$AverageTemperatureUncertainty, name = reactive({
        paste(input$tab2_countryB, "Temperature Uncertainity", sep = " - ")
      })(), type = "scatter") %>%
      layout(title = layout_title(), xaxis = x, yaxis = y, margin = 220)
  })

  # Tab 3 Processings
  output$tab3_plot_area <- renderPlotly({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_countries))
    plot_ly(y = ~ tab3_extract_data$AverageTemperature, type = "bar") %>%
      layout(title = input$tab3_countries, xaxis = x_bar, yaxis = y, margin = 220)
  })
}

# Get going
shinyApp(ui = ui, server = server)
