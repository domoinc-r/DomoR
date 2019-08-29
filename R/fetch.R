#' Fetch a data source.
#'
#' Retrieves a data source by ID (GUID) or by
#' previous list() index from Domo,
#' converts it to a data.frame and returns.
#'
#' @param id A data source id (GUID) or an index from a previous list.
#' @param columns A vector of column names to return from the Domo datasource. (not case sensitive)
#' @param use.make.names Logical. \code{TRUE} for change column names to
#'   a syntactically valid name. See \code{\link[base]{make.names}}.
#' @param ... Additional httr options
#' @return A \code{data.frame} built from the requested Domo data source.
#' @export
#' @examples
#' \dontrun{
#'   DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#'   df <- DomoR::fetch('4826e3fb-cd23-468d-9aff-96bf5b690247')
#'   DomoR::list_ds(limit=10)
#'   df <- DomoR::fetch(1)
#'   df <- DomoR::fetch('4826e3fb-cd23-468d-9aff-96bf5b690247',
#'                      c('accountid', 'lastname', 'startdate'),
#'                      httr::progress())
#' }
fetch <- function(id, columns = NULL, use.make.names=FALSE, ...) {

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

  get_url <- paste0(.domo_env$customer.url, '/api/data/v2/datasources/', data_source_id, '/dataversions/latest?includeHeader=true')

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                     'Accept'='text/csv'))

  get_result <- httr::GET(get_url, all.headers, .domo_env$config, ...)

  # handle errors
  httr::stop_for_status(get_result)

  guessEncoding <- readr::guess_encoding(get_result$content)

  if(is.null(guessEncoding)){
    guessEncodingValue <- 'UTF-8'
  }else{
    guessEncodingValue <- guessEncoding$encoding[1]
    if(guessEncodingValue=='ASCII'){
      guessEncodingValue <- 'UTF-8'
    }
  }

  df <- httr::content(get_result,na=c('\\N'),encoding=guessEncodingValue, ...) # type="domo/csv"

  if(use.make.names){
    names(df) <- make.names(tolower(names(df)))
  }

  return(data.frame(df))
}
