library(shiny)
library(plotly)
library(dplyr)
library(plyr)
library(Hmisc)
library(tseries)
library(forecast)

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
        helpText("Please select a country from the dropdown")
      ),
      mainPanel(
        plotlyOutput("tab21_plot_area"),
        hr(),
        plotlyOutput("tab22_plot_area"),
        hr(),
        plotlyOutput("tab23_plot_area")
      )
    ),
    # Tab 3
    tabPanel(
      title = "Time Series",
      sidebarPanel(
        selectInput("tab3_country", "Country:",
                    choices = countries,
                    selected = "India"
        ),
        hr(),
        helpText("Please select a country from the dropdown")
      ),
      mainPanel(
        plotOutput("tab31_plot_area"),
        hr(),
        plotOutput("tab33_plot_area"),
        hr(),
        plotOutput("tab34_plot_area"),
        hr(),
        verbatimTextOutput("tab3_adf_test"),
        hr(),
        plotOutput("tab35_plot_area"),
        hr(),
        plotOutput("tab36_plot_area"),
        hr(),
        verbatimTextOutput("tab3_arima_model"),
        hr(),
        plotOutput("tab37_plot_area"),
        hr(),
        verbatimTextOutput("tab3_forecast_model"),
        hr(),
        plotOutput("tab38_plot_area"),
        hr(),
        verbatimTextOutput("tab3_accuracy"),
        hr(),
        verbatimTextOutput("tab3_box_test"),
        hr(),
        plotOutput("tab39_plot_area"),
        hr(),
        plotOutput("tab311_plot_area")
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
  by_month_layout_title <- reactive({
    paste("Average Temperatures by Month", input$tab2_country, sep = " - ")
  })
  output$tab22_plot_area <- renderPlotly({
    tab2_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab2_country))
    avg_temp_by_month = select(tab2_extract_data, dt, AverageTemperature)
    avg_temp_by_month$dt= as.Date(avg_temp_by_month$dt)
    avg_temp_by_month = mutate(avg_temp_by_month, month = format(avg_temp_by_month$dt, format = '%m'), year = format(avg_temp_by_month$dt, format = '%Y'))
    avg_temp_by_month$month = as.factor(avg_temp_by_month$month)
    avg_temp_by_month$year = as.numeric(avg_temp_by_month$year)
    avg_temp_by_month = select(avg_temp_by_month, AverageTemperature, month, year)
    avg_plot_month <- ggplot(avg_temp_by_month, aes(x = month, y = AverageTemperature)) + geom_jitter(aes(colour = year)) + ggtitle(by_month_layout_title()) + labs(x = "Month", y = "Average Temperature") 
    avg_plot_month <- ggplotly()
  })
  by_var_layout_title <- reactive({
    paste("Temperature Variability", input$tab2_country, sep = " - ")
  })
  output$tab23_plot_area <- renderPlotly({
    tab2_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab2_country))
    temperature_uncer = select(tab2_extract_data, AverageTemperatureUncertainty, dt)
    temperature_uncer$dt = as.Date(temperature_uncer$dt)
    temperature_uncer = mutate(temperature_uncer, month = format(temperature_uncer$dt, '%m'), year = format(temperature_uncer$dt, '%Y'))
    temperature_uncer = select(temperature_uncer, AverageTemperatureUncertainty, month, year)
    temperature_uncer$year = as.numeric(temperature_uncer$year)
    temperature_uncer_plot <- ggplot(temperature_uncer, aes(x = month, y = AverageTemperatureUncertainty)) + geom_jitter(aes(colour = year)) +  ggtitle(by_var_layout_title()) + labs(x = "Month", y = "Temperature Variability") 
    temperature_uncer_plot <- ggplotly()
  })
  # Plotting the data
  output$tab31_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    plot(tab3_extract_data)
  })
  # Converting the data to a time series and plotting it
  output$tab33_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    plot.ts(tab3_extract_data)
  })
  # decomposing a time series into it's component i.e , trend,seasonality,irregular component
  output$tab34_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    time_data=decompose(tab3_extract_data)
    plot(time_data)
  })
  # Augmented Dickey-Fuller Test(adf.test) to check stationary
  output$tab3_adf_test <- renderPrint({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    adf.test(tab3_extract_data,alternative = "stationary")
  })
  # ACF plot
  output$tab35_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    acf(tab3_extract_data,lag.max = 20)
  })
  # PACF Plot
  output$tab36_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    pacf(tab3_extract_data,lag.max=20)
  })
  # fitting an arima model
  output$tab3_arima_model <- renderPrint({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    auto.arima(tab3_extract_data)
  })
  # Arima model plot
  output$tab37_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model_opt = auto.arima(tab3_extract_data)
    plot(model_opt)
  })
  # forecasting the model 10 levels ahead
  output$tab3_forecast_model <- renderPrint({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model = auto.arima(tab3_extract_data)
    forecast(model,h=50,level=c(80,95,99))
  })
  # forecast model plot
  output$tab38_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data = ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model = auto.arima(tab3_extract_data)
    model_forecast = forecast(model,h=50,level=c(80,95,99))
    plot(model_forecast,col="red")
  })
  # finding the accuracy of the model
  output$tab3_accuracy <- renderPrint({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model = auto.arima(tab3_extract_data)
    model_forecast = forecast(model,h=50,level=c(80,95,99))
    acc=accuracy(model_forecast)
    # acc[,5]=MAPE (Mean Absolute Percent Error) MAPE measures the size of the error in percentage terms
    cat(sprintf("accuracy: %f",100-acc[5]),"%") 
  })
  
  # investigating whether the forecast errors of an ARIMA model are normally distributed with mean zero and constant variance and whether there are any correlations between successive forecast errors.
  # test for checking the correlation between the residuals
  output$tab3_box_test <- renderPrint({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data=ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model = auto.arima(tab3_extract_data)
    model_forecast = forecast(model,h=50,level=c(80,95,99))
    Box.test(model_forecast$residuals,lag=20, type="Ljung-Box")
  })
  # make time plot of forecast errors
  output$tab39_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data = ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model = auto.arima(tab3_extract_data)
    model_forecast = forecast(model,h=50,level=c(80,95,99))
    plot.ts(model_forecast$residuals)
  })
  # residuals plot (residuals are roughly normally distributed)
  output$tab311_plot_area <- renderPlot({
    tab3_extract_data <- isolate(subset(countries_data, countries_data$Country == input$tab3_country))
    tab3_extract_data$dt = as.Date(tab3_extract_data$dt)
    tab3_extract_data = ts(tab3_extract_data$AverageTemperature,frequency = 12)
    model = auto.arima(tab3_extract_data)
    model_forecast = forecast(model,h=50,level=c(80,95,99))
    hist(model_forecast$residuals,col="red",probability = T)
    lines(density(model_forecast$residuals),col="blue",lwd=2,lty=5)
  })
}

# Get going
shinyApp(ui = ui, server = server)
