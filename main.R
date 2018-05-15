library(shiny)
library(plotly)
library(dplyr)
library(plyr)

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
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
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
          div(id = "plot-container",
              div(class = "plotlybars-wrapper",
                    div( class="plotlybars",
                           div(class="plotlybars-bar b1"),
                            div(class="plotlybars-bar b2"),
                            div(class="plotlybars-bar b3"),
                            div(class="plotlybars-bar b4"),
                            div(class="plotlybars-bar b5"),
                            div(class="plotlybars-bar b6"),
                            div(class="plotlybars-bar b7")
                    ),
                     div(class="plotlybars-text",
                           p("Updating the plot. Hold tight!")
                    )
              ),
               plotlyOutput("tab1_plot_area")
          )
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
        div(id = "plot-container"
            , div(class = "plotlybars-wrapper"
                  , div( class="plotlybars"
                         , div(class="plotlybars-bar b1")
                         , div(class="plotlybars-bar b2")
                         , div(class="plotlybars-bar b3")
                         , div(class="plotlybars-bar b4")
                         , div(class="plotlybars-bar b5")
                         , div(class="plotlybars-bar b6")
                         , div(class="plotlybars-bar b7")
                  )
                  , div(class="plotlybars-text"
                        , p("loading")
                  )
            )
            , plotlyOutput("tab2_plot_area")
        )
      )
    ),
    # Tab 3
    tabPanel(
      title = "Average Temperature (Bar Chart)",
      mainPanel(
        div(id = "plot-container"
            , div(class = "plotlybars-wrapper"
                  , div( class="plotlybars"
                         , div(class="plotlybars-bar b1")
                         , div(class="plotlybars-bar b2")
                         , div(class="plotlybars-bar b3")
                         , div(class="plotlybars-bar b4")
                         , div(class="plotlybars-bar b5")
                         , div(class="plotlybars-bar b6")
                         , div(class="plotlybars-bar b7")
                  )
                  , div(class="plotlybars-text"
                        , p("loading")
                  )
            )
            , plotlyOutput("tab3_plot_area")
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
  # Filling the space with plot using plotly
  output$tab1_plot_area <- renderPlotly({
    # Extracting selected country data from whole data
    tab1_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab1_countries))
    # We only need two columns from it
    date <- tab1_extract_data$dt
    avg_temperature <- tab1_extract_data$AverageTemperature
    Sys.sleep(3)
    data_frame <- data.frame(date, avg_temperature)
    x_tab1 <- list(
      title = "Date",
      titlefont = custom_font,
      tickangle = 50
    )
    y_tab1 <- list(
      title = "Average Temperature",
      titlefont = custom_font
    )
    plot_ly(data_frame, x = ~ date, y = ~ avg_temperature, type = "scatter", mode = "lines") %>%
    layout(title = input$tab1_countries, xaxis = x_tab1, yaxis = y_tab1, margin = 220)
  })

  # Tab 2 processings
  # Extract 2 countries data
  layout_title <- reactive({
    paste(input$tab2_countryA, input$tab2_countryB, sep = " and ")
  })
  output$tab2_plot_area <- renderPlotly({
    tab2_extract_data_countryA_raw <- isolate(subset(countries_data, countries_data$Country == input$tab2_countryA))
    tab2_extract_data_countryB_raw <- isolate(subset(countries_data, countries_data$Country == input$tab2_countryB))
    a_rows <- nrow(tab2_extract_data_countryA_raw)
    b_rows <- nrow(tab2_extract_data_countryB_raw)
    if (a_rows > b_rows) {
      tab2_extract_data_countryA <- isolate(sample_n(tab2_extract_data_countryA_raw, b_rows, replace = FALSE))
      tab2_extract_data_countryB <- tab2_extract_data_countryB_raw
    } else {
      tab2_extract_data_countryA <- tab2_extract_data_countryA_raw
      tab2_extract_data_countryB <- isolate(sample_n(tab2_extract_data_countryB_raw, a_rows, replace = FALSE))
    }
    x_tab2 <- list(
      title = input$tab2_countryA,
      titlefont = custom_font
    )
    y_tab2 <- list(
      title = input$tab2_countryB,
      titlefont = custom_font
    )
    Sys.sleep(3)
    plot_ly(data.frame(tab2_extract_data_countryA$AverageTemperature, tab2_extract_data_countryB$AverageTemperature), x = ~ tab2_extract_data_countryA$AverageTemperature, y = ~ tab2_extract_data_countryB$AverageTemperature, name = reactive({
      paste(input$tab2_countryA, input$tab2_countryB, sep = " - ")
    })(), type = "scatter") %>%
      layout(title = layout_title(), xaxis = x_tab2, yaxis = y_tab2, margin = 220)
  })

  # Tab 3 Processings
  output$tab3_plot_area <- renderPlotly({
    plot_data <- isolate(ddply(countries_data, ~ Country, summarise, avg_temperature = mean(unique(AverageTemperature))))
    x_tab3 <- list(
      title = "Countries",
      titlefont = custom_font,
      tickangle = 40
    )
    y_tab3 <- list(
      title = "Average Temperature",
      titlefont = custom_font
    )
    plot_ly(x = ~ plot_data$Country, y = ~ plot_data$avg_temperature, type = "bar") %>%
      layout(title = "Averaged across time series", xaxis = x_tab3, yaxis = y_tab3, margin = 220)
  })
}

# Get going
shinyApp(ui = ui, server = server)
