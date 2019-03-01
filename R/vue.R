#' Create a Vue App
#'
#'
#' @import htmlwidgets
#'
#' @export
#' @import htmltools
#' @import htmlwidgets
vue <- function(html, data = list(), dependencies = list(), watch = list(),
    id = NULL, ..., width = "100%", height = "auto", elementId = NULL) {

  if (!is.null(html)){
    if (is.null(html$attribs$id)){
      html$attribs$id <- paste0('vue-', htmlwidgets:::createWidgetId())
    }
    id <- html$attribs$id
    html_rendered <- htmltools::renderTags(html)
  } else {
    html_rendered <- list(html = "")
  }

  trim_underscore <- function(x){
    as.list(gsub("(^.*)\\_$", "\\1", x))
  }

  if (length(data) > 0 && is.list(data)){
    to_watch <- names(data)[endsWith(names(data), "_")]
    watch <- if (length(to_watch) > 0){
      append(watch, do.call(vueUpdateShinyInputs, trim_underscore(to_watch)))
    } else {
      list()
    }
    names(data) <- trim_underscore(names(data))
  }

  # forward options using x
  x = list(
    html = html_rendered$html,
    app = list(
      el = paste0("#", id),
      data = data,
      watch = watch,
      components = vueComponents$get(),
      ...
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'vue',
    x,
    width = width,
    height = height,
    package = 'vuer',
    elementId = elementId,
    dependencies = append(
      html_rendered$dependencies, dependencies
    )
  )
}

#' Create a Vue App
#'
#'
#' @export
#' @import htmltools
#' @examples
#' library(htmltools)
#' tags$div(
#'   tags$label('Enter your name'),
#'   tags$input(type = "text", "v-model" = "name"),
#'   tags$p("Hello {{name}}")
#'   ) %>%
#'   Vue(data = list(name = ""))
#'
#' if (interactive()){
#'   library(shiny)
#'   ui <- tags$div(
#'     tags$label('Enter your name'),
#'     tags$input(type = "text", "v-model" = "name"),
#'     textOutput("greeting")
#'   ) %>%
#'     Vue(data = list(name_ = ""))
#'   server <- function(input, output, session){
#'     output$greeting <- renderText({
#'       paste("Hello", input$name)
#'     })
#'   }
#'   shinyApp(ui = ui, server = server)
#' }
Vue <- function(html, data = list(), dependencies = list(), ...,
    elementId = NULL){
  if (is.null(html$attribs$id)){
    html$attribs$id <- paste0('vue-', htmlwidgets:::createWidgetId())
  }
  tagList(
    html,
    vue(html = NULL, data = data, dependencies = dependencies,
      elementId = elementId,
      id = html$attribs$id, ...
    )
  ) %>%
    browsable()
}

#' Shiny bindings for hello
#'
#' Output and render functions for using hello within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a hello
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name vue
#'
#' @export
vueOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'vue', width, height, package = 'vuepkg')
}

#' @rdname vue
#' @export
renderVue <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, helloOutput, env, quoted = TRUE)
}


#' Send commands to a Vue instance in a Shiny app
#'
#'
#' @examples
#' ui <- div(
#'   tags$label("Enter username"),
#'   tags$input(type = 'text', "v-model" = "username"),
#'   tags$p("Vue -> Vue: Hello {{username}}"),
#'   actionButton("set_name", "Shiny -> Vue"),
#'   verbatimTextOutput("username")
#' ) %>%
#'   vue(
#'     data = list(username = ""),
#'     # Vue UI -> Shiny UI
#'     watch = vue_watch("username"),
#'    elementId = "app"
#'  )
#' server <- function(input, output, session){
#'   # Shiny server -> Vue UI
#'   observeEvent(input$set_name, {
#'     vueProxy("app") %>%
#'       updateProp("username", "Ramnath")
#'   })
#'   output$username <- renderPrint({
#'     paste("Vue -> Shiny:", input$username)
#'   })
#' }
#' shiny::shinyApp(ui = ui, server = server)
#' @export
vueProxy <- function(outputId, session = shiny::getDefaultReactiveDomain(),
    deferUntilFlush = TRUE){
  if (is.null(session)){
    stop("vueProxy() must be called from the server function of a Shiny app")
  }
  structure(list(
      id = session$ns(outputId),
      rawId = outputId,
      session = session,
      deferUntilFlush = deferUntilFlush
    ), class = 'vue_proxy'
  )
}

#' Update data in a Vue instance
#' @export
#' @rdname vueProxy
vueUpdateData <- function(proxy, ...){
  message <- list(id = proxy$id, data = asPropsList(list(...)))
  proxy$session$sendCustomMessage(type = "updateProp", message = message)
  return(proxy)
}

#' Update Shiny Input
#'
#' @export
vueUpdateShinyInputs <- function(...){
  dots <- list(...)
  dots %>%
    purrr::map(~ {
      htmlwidgets::JS(sprintf("function(val){
         console.log(val)
         Shiny.setInputValue('%s', val)
      }", .x))
    }) %>%
    rlang::set_names(dots)
}



.generator <- function(){
  .vueComponents <- list()
  list(
    get = function(){
        return(.vueComponents)
    },
    register = function(..., .list = NULL){
      if (is.null(.list)) .list = list(...)
      .list <- .list %>%
        purrr::map(htmlwidgets::JS)
      .vueComponents <<- append(.vueComponents, .list)
    },
    reset = function(){
      .vueComponents <<- list()
    }
  )
}

#' @export
vueComponents <- .generator()


