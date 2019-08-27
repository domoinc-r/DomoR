
# add empty .domo_env as parent
.domo_env <- new.env()

.onLoad <- function(libname, pkgname) {
  packageStartupMessage("Welcome to DomoR")
}

#' Initialize Domo package
#'
#' @param customer The customer ID or base URL.  e.g.  acme.domo.com  or  acme
#' @param token The DEV token required for API access.
#' @export
#' @examples
#' \dontrun{
#'   DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#' }
init <- function(customer,
                       token,
                       config=NULL,
                       verbose=FALSE) {

  # check pluginstatus
  get_pluginstatus_result <- httr::GET('https://s3.amazonaws.com/domoetl/get/R2.json')

  if(get_pluginstatus_result$status != 403) {

    # handle errors
    httr::stop_for_status(get_pluginstatus_result)

    result_content <- httr::content(get_pluginstatus_result, as="parsed",type="application/json")

    if(result_content$deprecated[1]){
      warning(result_content$message[1])
    }

    if(result_content$obsolete[1]){
      stop(result_content$message[1])
    }

  }

  if(missing(customer)) {
    stop('A customer instance is required')
  }
  else {
    stopifnot(is.character(customer))
  }

  if(missing(token)) {
    stop('A token is required')
  }

  .domo_env$customer <- customer
  .domo_env$customer.url <- paste0("https://", with.suffix(customer))

  if (nchar(token) < 70)
    .domo_env$auth.token <- c('X-DOMO-Developer-Token'=token)
  else
    .domo_env$auth.token <- c('X-DOMO-Authentication'=token)

  .domo_env$user.agent <- c("User-Agent"="DomoR-test/1.0")

  if(is.null(config)) {
    if(verbose == TRUE) {
      assign("config", c(verbose=TRUE), .domo_env)
    }
    else {
      assign("config", c(), .domo_env)
    }
  }
  else {
    assign("config", config, .domo_env)
  }
}

with.suffix <- function (customer, suffix = '.domo.com') {
  ifelse (substring(tolower(customer), nchar(customer)-nchar(suffix)+1) == tolower(suffix),
          customer,
          paste0(customer, suffix))
}
