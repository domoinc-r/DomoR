lookup_stream <- function (dataset_id) {
  search_stream('dataSource.id', dataset_id)
}

search_stream <- function (key, value) {
  get_url <- paste0(.domo_env$customer.url, '/api/data/v1/streams/search?q=', key, ':', value)

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,'Accept'='application/json'))

  response <- httr::GET(get_url,all.headers,.domo_env$config)

  httr::stop_for_status(response)

  response_content <- httr::content(response)

  if(length(response_content) < 1)
    stop(paste("unable to find stream for", value))
  #print(response_content)
  #response_content[[1]]$id
  response_content[[1]]
}

schema_domo <- function(data_source_id){
  get_url <- paste0(.domo_env$customer.url, '/api/data/v2/datasources/', data_source_id, '/schemas/latest')
  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,'Accept'='application/json'))
  response <- httr::GET(get_url,all.headers,.domo_env$config)

  httr::stop_for_status(response)
  response_content <- httr::content(response)
  response_content$schema$objects <- NULL

  columns <- list()
  for( i in 1:length(response_content$schema$columns)){
    columns$name[length(columns$name)+1] <- response_content$schema$columns[[i]]$name
    columns$type[length(columns$type)+1] <- response_content$schema$columns[[i]]$type
  }

  return(columns)
}

schema_definition <- function (data) {
  schema <- schema_data(data)
  schema_def <- NULL
  schema_def$columns <- list()
  for (i in 1:length(schema$name)) {
    schema_def$columns[[i]] <- list()
    schema_def$columns[[i]]$name <- schema$name[i]
    schema_def$columns[[i]]$type <- schema$type[i]
  }

  return(schema_def)
}

schema_data <- function(data) {
  schema <- list()
  if(!is.null(data)) {
    for (i in 1:ncol(data)) {
      t.name <- names(data)[i]
      t.type <- typeConversionText(data,i)
      schema$name[length(schema$name)+1] <- t.name
      schema$type[length(schema$type)+1] <- t.type
    }
  }

  return(schema)
}

typeConversionText <- function(data, colindex) {
  vec <- data[, colindex, drop = TRUE]
  cls <- class(vec)[1L]
  if (cls %in% c("numeric", "ts"))                return("DOUBLE")
  if (cls %in% c("character", "factor"))          return("STRING")
  if (cls == "integer")                           return("LONG")
  if (cls == 'Date')                              return("DATE")
  if (cls %in% c("POSIXct", "POSIXlt", "POSIXt")) return("DATETIME")
  return("STRING")
}
