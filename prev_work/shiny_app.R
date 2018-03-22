library(shiny)
library(ggvis)

ui <- fluidPage(
  tabsetPanel(
    tabPanel(
      title = "Home",
      sidebarLayout(
        sidebarPanel(
          sliderInput(inputId = "num1", label = "Number Of Observation", value = 20, min = 1, max = 100),
          textInput(inputId = "txt", label = "X axis Label", value = "Histogram"),
          actionButton(inputId = "go1", label = "Update")
        ),
        mainPanel(ggvisOutput(plot_id = "hist1"))
      )
    ),

    tabPanel(
      title = "Normal Distribution",
      sidebarLayout(
        sidebarPanel(
          numericInput(inputId = "nobs", label = "Number Of Observation", value = 20, min = 1, max = 100),
          numericInput(inputId = "nmean", label = "Mean", value = 0),
          numericInput(inputId = "nsd", label = "Standard Deviations", value = 1),
          textInput(inputId = "ntxt", label = "X axis Label", value = "Histogram"),
          actionButton(inputId = "go2", label = "Update")
        ),
        mainPanel(ggvisOutput(plot_id = "hist2"))
      )
    ),

    tabPanel(
      title = "Uniform Distribution",
      sidebarLayout(
        sidebarPanel(
          numericInput(inputId = "uobs", label = "Number Of Observation", value = 20, min = 1, max = 100),
          numericInput(inputId = "umin", label = "Lower Limit", value = 0),
          numericInput(inputId = "umax", label = "Upper Limit", value = 1),
          textInput(inputId = "utxt", label = "X axis Label", value = "Histogram"),
          actionButton(inputId = "go3", label = "Update")
        ),
        mainPanel(ggvisOutput(plot_id = "hist3"))
      )
    ),

    tabPanel(
      title = "Exponential Distribution",
      sidebarLayout(
        sidebarPanel(
          numericInput(inputId = "eobs", label = "Number Of Observation", value = 20, min = 1, max = 100),
          numericInput(inputId = "erate", label = "Rate", value = 1),
          textInput(inputId = "etxt", label = "X axis Label", value = "Histogram"),
          actionButton(inputId = "go4", label = "Update")
        ),
        mainPanel(ggvisOutput(plot_id = "hist4"))
      )
    )
  )
)

server <- function(input, output) {
  data1 <- reactive({
    data.frame(first = sample(1:input$num1, input$num1, replace = T))
  })
  observeEvent(input$go1, {
    output$hist1 <- reactive({
      isolate(data1() %>% ggvis(x = ~ first)) %>% layer_histograms(fill := "#436EEE", fill.hover := "#FFA500") %>% add_axis("x", title = isolate({
        input$txt
      })) %>% bind_shiny("hist1")
    })
  })

  data2 <- reactive({
    data.frame(second = rnorm(input$nobs, input$nmean, input$nsd))
  })
  observeEvent(input$go2, {
    output$hist2 <- reactive({
      isolate(data2() %>% ggvis(x = ~ second)) %>% layer_histograms(fill := "#436EEE", fill.hover := "#FFA500") %>% add_axis("x", title = isolate({
        input$ntxt
      })) %>% bind_shiny("hist2")
    })
  })

  data3 <- reactive({
    data.frame(third = runif(input$uobs, input$umin, input$umax))
  })
  observeEvent(input$go3, {
    output$hist3 <- reactive({
      isolate(data3() %>% ggvis(x = ~ third)) %>% layer_histograms(fill := "#436EEE", fill.hover := "#FFA500") %>% add_axis("x", title = isolate({
        input$utxt
      })) %>% bind_shiny("hist3")
    })
  })

  data4 <- reactive({
    data.frame(fourth = rexp(input$eobs, input$erate))
  })
  observeEvent(input$go4, {
    output$hist4 <- reactive({
      isolate(data4() %>% ggvis(x = ~ fourth)) %>% layer_histograms(fill := "#436EEE", fill.hover := "#FFA500") %>% add_axis("x", title = isolate({
        input$etxt
      })) %>% bind_shiny("hist4")
    })
  })
}


shinyApp(ui = ui, server = server)
