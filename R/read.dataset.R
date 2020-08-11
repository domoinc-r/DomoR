#' Read a dataset
#'
#' Retrieves a data set by name
#' converts it to a data.frame and returns.
#' Provides compatability with domomagic read.dataframe()
#'
#' @param name A data source name
#' @param ... Additional options
#' @return A \code{data.frame} built from the requested Domo data set
#' @export
#' @examples
#' DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#' df <- DomoR::read.dataset('TEST | Data')
read.dataset <- function(name, strip.white=FALSE, ...) {

  # check that required env variables exist
  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  id <- list_ds(name = name)['id']
  df <- fetch(id,strip.white=strip.white, ...)

  return(data.frame(df))
}
