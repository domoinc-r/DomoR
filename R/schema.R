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

  result <- 'STRING' #default column type

  date_time <- convertDomoDateTime(data[,colindex])

  if(!is.na(date_time[1])){
    type <- class(date_time)[1]
    if(type == 'Date') result <- 'DATE'
    if(type == 'POSIXct') result <- 'DATETIME'
    if(type == 'POSIXlt') result <- 'DATETIME'
  }else{
    type <- class(data[,colindex])[1]
    if(type == 'character') result <- 'STRING'
    if(type == 'numeric') result <- 'DOUBLE'
    if(type == 'integer') result <- 'LONG'
    if(type == 'Date') result <- 'DATE'
    if(type == 'POSIXct') result <- 'DATETIME'
    if(type == 'factor') result <- 'STRING'
    if(type == 'ts') result <- 'DOUBLE'
  }
  return(result)
}
