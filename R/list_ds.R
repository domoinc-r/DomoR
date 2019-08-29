#' List data sources
#'
#' @param limit Maximum number of entries to return.  If limit is less than 1, list all datasets that match criteria.
#' @param name Filter by partial dataset name (not case sensitive)
#' @param offset Starting index into the result
#' @param owner_id Filter by dataset owner ID
#' @param display_type Filter results by type.  e.g. 'salesforce'
#' @param data_provider Filter results by authorization type.  e.g. 'salesforce'
#' @param order_by Order the results by column.  e.g. 'name'
#' @return A \code{data.frame} containing a list of available datasets
#' @export
#' @examples
#' \dontrun{
#'   DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#'   DomoR::list_ds()
#'   DomoR::list_ds(limit=10, name="sales+results")
#' }
list_ds <- function(limit=50, name=NULL, offset=0, owner_id=NULL, display_type=NULL, data_provider=NULL, order_by=NULL) {

  # check that required env variables exist
  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  if (limit > 50) {
    limit = 50
    warning('using maximum request limit of 50')
  }

  # optional parameters
  limit_param <- paste0('&limit=', ifelse(limit < 1, 50, limit))

  name_param <- ''
  if(!is.null(name)) {
    name_param <- paste0('&nameLike=', utils::URLencode(name))
  }

  owner_id_param <- ''
  if(!is.null(owner_id)) {
    owner_id_param <- paste0('&ownerId=', owner_id)
  }

  display_type_param <- ''
  if(!is.null(display_type)) {
    display_type_param <- paste0('&displayType=', display_type)
  }

  data_provider_param <- ''
  if(!is.null(data_provider)) {
    data_provider_param <- paste0('&dataProviderType=', data_provider)
  }

  order_by_param <- ''
  if(!is.null(order_by)) {
    if(order_by %in% c('name', 'lastTouched', 'lastUpdated', 'cardCount', 'cardViewCount')) {
      order_by_param <- paste0('&orderBy=', order_by)
    }
    else {
      stop("Invalid 'order_by' paramter, valid options are: 'name', 'lastTouched', 'lastUpdated', 'cardCount', 'cardViewCount'")
    }
  }

  all_result <- NULL # data.frame()

  repeat {
    offset_param <- paste0('&offset=', offset)

    # make the request
    list_url <- paste0(.domo_env$customer.url, '/api/data/v3/datasources?fields=id,name',
                      limit_param, name_param, offset_param, owner_id_param, display_type_param, data_provider_param, order_by_param)

    all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                       'Content-Type'='application/json'))

    list_result <- httr::GET(list_url, all.headers, .domo_env$config, nullValue=NA)

    # handle errors
    httr::stop_for_status(list_result)

    r <- httr::content(list_result)$dataSources
    num_ds <- length(r)

    ds_meta <- data.frame(matrix(0,nrow=num_ds,ncol=17))

    names(ds_meta) <- c(
      'id',
      'displayType',
      'dataProviderType',
      'type',
      'name',
      'description',
      'owner.id',
      'owner.name',
      'created',
      'lastTouched',
      'lastUpdated',
      'nextUpdate',
      'updateFrequency',
      'rowCount',
      'columnCount',
      'cardInfo.cardCount',
      'cardInfo.cardViewCount')

    if (num_ds > 0) {
      for (i in 1:num_ds) {
        row <- unlist(r[[i]])
        for (j in names(ds_meta)) {
          if (is.null(row[j])) { ds_meta[i,j] <- 0 } else { ds_meta[i,j] <- row[j] }
        }
      }
    }

    date_vars <- c('created','lastTouched','lastUpdated','nextUpdate')
    for (key in date_vars) {
      ds_meta[ , key] <- as.POSIXct(as.numeric(ds_meta[ , key])/1000,origin='1970-01-01')
    }

    if(is.null(all_result))
      all_result <- data.frame(ds_meta)
    else
      all_result <- merge(all_result, data.frame(ds_meta), all=T)

    offset <- offset + num_ds

    if (num_ds < 50 || limit > 1) break;
  }

  # assign data source list to environment for easy retrieval by id
  assign("last_data_source_list", all_result$id, .domo_env)

  return(all_result)
}
