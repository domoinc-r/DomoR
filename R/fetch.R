#' Fetch a data source.
#'
#' Retrieves a data source by ID (GUID) or by
#' previous list() index from Domo,
#' converts it to a data.frame and returns.
#'
#' @param id A data source id (GUID) or an index from a previous list.
#' @param columns A vector of column names to return from the Domo datasource. (not case sensitive)
#' @param ... Additional httr options
#' @return A \code{data.frame} built from the requested Domo data source.
#' @export
#' @examples
#' DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#' df <- DomoR::fetch('4826e3fb-cd23-468d-9aff-96bf5b690247')
#' DomoR::list_ds(limit=10)
#' df <- DomoR::fetch(1)
#' df <- DomoR::fetch('4826e3fb-cd23-468d-9aff-96bf5b690247',
#'   c('accountid', 'lastname', 'startdate'),
#'   httr::progress())
fetch <- function(id, columns = NULL, use.make.names=F, ...) {

  # check that required env variables exist
  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  # if the id is a number, assume it's from a previous list of data sources
  data_source_id <- id

  if(is.numeric(id)) {
    if (!exists('last_data_source_list', .domo_env))
      stop("no previous run to index into", call. = F)
    ids <- get('last_data_source_list', .domo_env)
    data_source_id <- ids[[id]]
  }

  schema_cols <- schema_domo(data_source_id)
  unmatched <- columns[which(!tolower(columns) %in% tolower(schema_cols$name))]
  if(length(unmatched) > 0)
    warning (paste("unmatched columns:",  paste(unmatched, collapse = ", ")))

  if (length(columns) == 0) { # select all columns
    columns <- schema_cols$name
  }

  selectedColumns <- which(tolower(schema_cols$name) %in% tolower(columns))
  cc <- ifelse(c(1:length(schema_cols$name)) %in% selectedColumns, NA, "NULL")

  datetimeCols <- which(schema_cols$type %in% c("DATETIME","DATE"))
  cc[datetimeCols[which(datetimeCols %in% selectedColumns)]] <- NA # request only datetime cols in the result

  get_url <- paste0(.domo_env$customer.url, '/api/data/v2/datasources/', data_source_id, '/dataversions/latest?includeHeader=true')

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                     'Accept'='text/csv'))

  get_result <- httr::GET(get_url, all.headers, .domo_env$config, ...)

  # handle errors
  httr::stop_for_status(get_result)

  df <- httr::content(get_result,check.names=FALSE,na.strings='\\N',as="parsed", colClasses=cc) # type="domo/csv"

  selectedDatetimeCols <- datetimeCols[datetimeCols %in% selectedColumns] # convert only datetime cols that will be in the result
  convertDatetimeCols <- which(names(df) %in% schema_cols$name[selectedDatetimeCols]) # find those columns in the result set
  for (i in convertDatetimeCols) {
    df[i] <- convertDomoDateTime(df[[i]])
  }
  if(use.make.names){
    names(df) <- make.names(tolower(names(df)))
  }
  return(df)
}

column.names <- function (data_source_id) {

  get_url <- paste0(.domo_env$customer.url, '/api/data/v2/datasources/', data_source_id, '/schemas/latest')

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                     'Accept'='application/json'))

  get_result <- httr::GET(get_url,
                          all.headers,
                          .domo_env$config)

  httr::stop_for_status(get_result)

  jsontext <- httr::content(get_result,as="raw")

  jsonlite::fromJSON(rawToChar(jsontext), flatten=T)$schema$columns$name
}

#setAs("character","DomoDateTime", function(from) convertDomoDateTime(from))

convertDomoDateTime <- function(v) {

  date_time <- as.POSIXct(strptime(v,"%Y-%m-%dT%H:%M:%S"))
  if (is.na(date_time[1]))
    date_time <- as.POSIXct(strptime(v,"%Y-%m-%d %H:%M:%S"))
  if (is.na(date_time[1]))
    date_time <- tryCatch({ as.Date(v) }, error = function(err) { NA })

  return(date_time)
}


coalesce <- function(...) {
  Reduce(function(x, y) {
    i <- which(is.na(x))
    x[i] <- y[i]
    x},
    list(...))
}

