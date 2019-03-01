asPropsList <- function (x, name = "name", value = "value"){
  x <- as.list(x)
  nms <- names(x)
  lapply(seq_along(x), function(i) {
    l <- list()
    l[name] <- nms[i]
    l[value] <- x[i]
    l
  })
}


#' Use a vue Plugin
#'
#'
#' @export
vueUsePlugin <- function(fun){
  tags$script(sprintf("Vue.use(%s)", fun))
}

#' Append html dependencies
#'
#' NOTE: This function has been copied over from shinydashboard
#' @export
appendDependencies <- function (x, value){
  if (inherits(value, "html_dependency"))
    value <- list(value)
  old <- attr(x, "html_dependencies", TRUE)
  htmlDependencies(x) <- c(old, value)
  x
}
