library(vuer)

htmlDependenciesElementUI <- function(){
  list(
    htmlDependency(
      name = 'vue',
      version = '2.6.6',
      src = system.file('htmlwidgets', 'lib','vue', package = 'vuer'),
      script = "vue.js"
    ),
    htmlDependency(
      name = 'element-ui',
      version = '2.6.0',
      src = c(href = "https://unpkg.com/element-ui/lib"),
      script = "index.js",
      stylesheet = "theme-chalk/index.css"
    )
  )
}



create_tags <- function(types, prefix){
  types %>%
    purrr::map(~ {
      function(...){
        tag(paste0(prefix, '-', .x), list(...))
      }
    }) %>%
    rlang::set_names(
      tag_types %>%
        stringr::str_replace("-", "_")
    )
}


types <- c('button', 'color-picker')
el_tags <- create_tags(types, 'el')

el_tags$button(type = 'Primary', "Primary") %>%
  appendDependencies(htmlDependenciesElementUI()) %>%
  Vue()

el_tags$color_picker("v-model" = "color") %>%
  appendDependencies(htmlDependenciesElementUI()) %>%
  Vue(data = list(color = '#fff'))

