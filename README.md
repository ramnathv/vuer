## vuer <img src="https://i.imgur.com/HHzsuI9.png" width='70px'/>

`vuer` is an R package that makes it easy to use Vue components and build Vue apps.

> Vue (pronounced /vjuː/, like view) is a progressive framework for building user interfaces. It is designed from the ground up to be incrementally adoptable, and can easily scale between a library and a framework depending on different use cases.


## Installation

You can install `vuer` from github using `remotes` or `devtools`.

```{r}
remotes::install_github('ramnathv/vuer')
```

## Usage

### Example 1: Hello World

We can use `vuer` to create purely client-side web-apps taking advantage of its simple API and two-way data bindings. In this simple example, we let a user enter their name and display a greeting message. 

```{r}
tags$div(style = 'height:100px;width:400px;',
  tags$label('Enter your name: '),
  tags$input(type = "text", "v-model" = "name"),
  tags$p(class = "lead", "Hello {{name}}")
) %>% 
  appendDependencies(
    htmldeps::html_dependency_bootstrap('cosmo')
  ) %>%
  Vue(data = list(name = ""))
```

![hello-world](https://media.giphy.com/media/QmKxl4fJZtAEHkepJM/giphy.gif)

The power of `vuer` starts truly shining when we are able to let Vue communicate with Shiny. This opens up an unlimited range of possibilities that we will explore in detail. The next two examples explore how Vue and Shiny can communicate with each other.

### Example 2: Vue -> Shiny

It is dead-simple to let Vue communicate with Shiny. All it takes is adding an underscore at the end of any data variable passed to `Vue`. This automatically sets up watcher functions to update shiny when the underlying value changes, thereby triggering any reactive paths that depend on it. This example is very similar to the first one in that we let a user enter their name and display a greeting message. The key difference is that the greeting message is from Shiny on the server side.

```{r}
ui <- fluidPage(theme = shinythemes::shinytheme("cosmo"),
  tags$div(
    tags$label('Enter your name'),
    tags$input(type = "text", "v-model" = "name"),
    uiOutput("greeting")
  ) %>% 
  Vue(
    data = list(name_ = "")
  )
)


server <- function(input, output, session){
  output$greeting <- renderUI({
    tags$p(paste("Hello", input$name))
  })
}

shinyApp(ui = ui, server = server)
```


### Example 3: Shiny -> Vue

It is equally easy to let Shiny communicate with Vue. In this example we pass the coordinates of a plot brush to Vue and display it as JSON.

```{r}
library(shiny)
library(ggplot2)
library(vuer)
ui <- fluidPage(theme = shinythemes::shinytheme("cosmo"),
  titlePanel(title = 'Shiny -> Vue'),
  mainPanel(
    plotOutput('plot', brush = brushOpts('plot_brush'), height = '300'),
    tags$pre("v-if" = "plot_brush !== null", 
      tags$code("{{plot_brush}}")
    ) %>% 
      Vue(data = list(plot_brush = c()), elementId = "app")
  )
)

server <- function(input, output, session){
  output$plot <- renderPlot({
    ggplot(mtcars, aes(x = mpg, y = wt)) +
      geom_point()
  })
  observeEvent(input$plot_brush, {
    vueProxy("app") %>% 
      vueUpdateData(plot_brush = input$plot_brush$coords_img)
  })
}
shinyApp(ui = ui, server = server)
```

![shiny-vue](https://media.giphy.com/media/c6XuxhQrLTUid7m76o/giphy.gif)


## Acknowledgements

This package was inspired by Kenton Russell's [experiments](https://github.com/timelyportfolio/vueR) using Vue in R, as well as the efforts taken by the [react-R](https://github.com/react-R/reactR) team in integrating `React.js` with R. 
