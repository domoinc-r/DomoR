#' Create a data source from a data.frame
#'
#' @param data A data.frame from which to create the dataset
#' @param name Name to assign the dataset on Domo
#' @param description Optional description of the dataset
#' @export
#' @examples
#' df <- data.frame(matrix(rnorm(20), nrow=10))
#' DomoR::create(df, name="My Data Source Name", description="My Data Source Description")
create <- function(data, name, description='') {

  # check that required env variables exist
  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  if(missing(name)) {
    warning('Data source will be created without a name')
  }

  if(missing(description)) {
    warning('Data source will be created without a description')
  }

  schema <- schema_definition(data)

  json <- list(transport=list(type="API"), dataSource=list(name=name, description=description),
            dataProvider=list(key="r", name="R"), schemaDefinition=list(columns=schema$columns))

  body <- jsonlite::toJSON(json,auto_unbox=T)

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                     'Content-Type'='application/json',
                                     'Accept'='application/json'))

  # issue request
  create_result <- httr::POST(paste0(.domo_env$customer.url, '/api/data/v1/streams'),
                              body=body, all.headers, .domo_env$config)

  httr::stop_for_status(create_result)

  # get the data source id
  create_json <- httr::content(create_result)

  ds <- create_json$dataSource$id
  #message(paste('Created datasource: ', ds))

  #use replace function to upload data.
  out <- DomoR::replace_ds(ds,data)
  return(ds)
}

