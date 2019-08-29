#' Fetch a data source to disk.
#'
#' Retrieves a data source by GUID, saves to temp file and converts it to a data.frame and returns.
#'
#' @param data_source_id A data source id (GUID)
#' @param nrows number of rows to return in dataframe by default returns all rows
#' @param delete.tmp.file temp file to save the data by default tmp_file is deleted
#' @return A \code{data.frame} built from the requested Domo data source
#' @export
#' @importFrom utils read.csv
#' @examples
#' \dontrun{
#'   DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#'   df <- DomoR::fetch_to_disk(data_source_id="4826e3fb-cd23-468d-9aff-96bf5b690247",
#'                              nrows=5,
#'                              delete.tmp.file=TRUE)
#' }

fetch_to_disk <- function(data_source_id, nrows=NULL, delete.tmp.file=TRUE) {

  # check that required env variables exist
  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  get_url <- paste0(.domo_env$customer.url, '/api/data/v2/datasources/', data_source_id, '/dataversions/latest?includeHeader=true')

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent, 'Accept'='text/csv'))

  tmp_file <- tempfile(fileext=".csv")

  print(paste0("Temp File Location :: ", tmp_file))

  get_result <- httr::GET(get_url, all.headers, .domo_env$config, httr::write_disk(tmp_file, overwrite=FALSE))

  # handle errors
  httr::stop_for_status(get_result)

  if(is.null(nrows)){
    df <- utils::read.csv(file=tmp_file, header = TRUE, sep = ",")
  }else{
    df <- utils::read.csv(file=tmp_file, header = TRUE, sep = ",", nrows=nrows)
  }

  if(delete.tmp.file){
    file.remove(tmp_file)
    print(paste0("Temp file deleted successfully from location :: ", tmp_file))
  }

  return(df)
}
