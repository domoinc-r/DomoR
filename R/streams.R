
stream.lookup <- function (id, ...) {
  get_url <- paste0(.domo_env$customer.url, "/api/data/v1/streams/search?q=dataSource.id:", id)

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent
                                     ,"Accept"="application/json"))

  get_result <- httr::GET(get_url, all.headers, .domo_env$config, ...)

  # handle errors
  httr::stop_for_status(get_result)

  json <- httr::content(get_result)

  stopifnot(nrow(json) > 0)

  return(json[[1]]$id)
}

stream.fetch <- function(id, columns = NULL, ...) {

}


stream.upload <- function(streamId) {
  # create execution
  #post_url <- paste0(.domo_env$customer.url, "/api/data/v1/streams")


  # send part

  # commit
}



# {"transport":{"type":"API"},"dataSource":{"name":"test streams data source","description":"no description"},
#  "dataProvider":{"key":"bamboo-hr","name":"Bamboo HR"},"schemaDefinition":{"columns":[{"name":"column1","type":"STRING"},{"name":"column2","type":"DATE"}]}}
test.stream.create <- function() {
  j <- NULL
  j$transport <- NULL
  j$transport$type <- "API"
  j$dataSource <- NULL
  j$dataSource$name <- "test streams data set"
  j$dataSource$description <- "no description"
  j$dataProvider <- NULL
  j$dataProvider$key <- "bamboo-hr"
  j$dataProvider$name <- "Bamboo HR"
  j$schemaDefinition <- NULL
  j$schemaDefinition$columns <- NULL
  columns <- list(
    list("name"="column1", "type"="STRING"),
    list("name"="column2", "type"="DATE")
  )
  j$schemaDefinition$columns <- columns
  print(jsonlite::toJSON(j, auto_unbox=T))
}

# {"transport":{"type":"API"},"dataSource":{"name":"test streams data source","description":"no description"},
#  "dataProvider":{"key":"bamboo-hr","name":"Bamboo HR"},"schemaDefinition":{"columns":[{"name":"column1","type":"STRING"},{"name":"column2","type":"DATE"}]}}
test.create.json <- function() {
  columns <- list(
    list("name"="column1", "type"="STRING"),
    list("name"="column2", "type"="DATE")
  )
  j <- list(transport=list(type="API"), dataSource=list(name="test streams data set", description="descr"),
       dataProvider=list(key="bamboo-hr", name="Bamboo HR"), schemaDefinition=list(columns=columns))
  print(jsonlite::toJSON(j, auto_unbox=T))
}
