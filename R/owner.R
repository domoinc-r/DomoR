#' Determine my Domo user ID
#'
#' @export
#' @examples
#' \dontrun{
#'   DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#'   DomoR::owner()
#' }
owner <- function() {

  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  get_url <- paste0(.domo_env$customer.url, '/api/content/v2/users/me')

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                     'Content-Type'='application/json',
                                     'Accept'='application/json'))

  get_result <- httr::GET(get_url, all.headers, .domo_env$config)

  # handle errors
  httr::stop_for_status(get_result)

  result <- httr::content(get_result,check.names=FALSE)

  return(result$id)

}
