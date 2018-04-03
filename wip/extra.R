library(shiny)
library(plotly)
library(dplyr)
library(plyr)
library(ISLR)
library(Hmisc)

raw_data <- read.delim("../data/GlobalLandTemperaturesByCountry.csv", sep = ",")
sum(is.na(raw_data))
countries_data <- na.omit(raw_data)
sum(is.na(countries_data))
colnames(countries_data)
countries <- unique(countries_data$Country)

ui <- fluidPage(
  titlePanel("Temperature Visualizations"),
  tabsetPanel(
    # Tab 1
    tabPanel(
      title = "Data Summary",
      div(
        style = "display:inline-block",
        mainPanel(
          h3("Summary of all countries"),
          #verbatimTextOutput("tab1_desc_text1"),
          div(style="width:1150px;",fluidRow(verbatimTextOutput("tab1_desc_text1"))),
          hr()
        )
      ),
      div(
        style = "display:inline-block",
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
            h3("Summary by country"),
            div(style="width:1150px;",fluidRow(verbatimTextOutput("tab1_desc_text")))
          )
        )
      )
    ),
    # Tab 2
    tabPanel(
      title = "Temperature changes (By country)",
      sidebarPanel(
        selectInput("tab2_country", "Country:",
          choices = countries,
          selected = "India"
        ),
        hr(),
        helpText("Please select two countries from the dropdown")
      ),
      mainPanel(
        plotlyOutput("tab21_plot_area"),
        hr(),
        plotlyOutput("tab22_plot_area")
      )
    )
  )
)


server <- function(input, output) {
  custom_font <- list(
    family = "Courier New, monospace",
    size = 18,
    color = "#7f7f7f"
  )
  output$tab1_desc_text1 <- renderPrint({
    describe(countries_data)
  })
  
  output$tab1_desc_text <- renderPrint({
    individual_country <- isolate(subset(countries_data, countries_data$Country == input$tab1_countries))
    describe(individual_country)
  })

  # Tab 2 Processings
  by_year_layout_title <- reactive({
    paste("Average Temperatures by Year", input$tab2_country, sep = " - ")
  })
  output$tab21_plot_area <- renderPlotly({
    tab2_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab2_country))
    avg_temp_by_year = isolate(select(tab2_extract_data, dt, AverageTemperature))
    avg_temp_by_year$dt = as.Date(avg_temp_by_year$dt )
    avg_temp_by_year$dt = format(avg_temp_by_year$dt , '%Y')
    avg_temp_by_year$dt = as.numeric(avg_temp_by_year$dt )
    avg_plot_year <- ggplot(avg_temp_by_year, aes(x = avg_temp_by_year$dt, y = avg_temp_by_year$AverageTemperature)) + geom_point() + ggtitle(by_year_layout_title()) + labs(x = "Year", y = "Average Temperature")
    avg_plot_year <- ggplotly()
  })
}

# Get going
shinyApp(ui = ui, server = server)
