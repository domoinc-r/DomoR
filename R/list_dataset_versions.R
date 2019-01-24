#' Determine dataversions based on dataset Id
#'
#' @param id A data source id (GUID)
#' @param use.dataversions.json TRUE returns pretty json output
#' @export
#' @examples
#' DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#' DomoR::list_dataset_versions(id='d0b246-3b41')
list_dataset_versions <- function(id, use.dataversions.json=FALSE){
  
  if(is.null(id)){
    stop("Datasource ID is a required field")
  }
  
  get_url <- paste0(.domo_env$customer.url, '/api/data/v3/datasources/', id, '/dataversions/details')
  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent, 'Content-Type'='application/json'))
  get_result <- httr::GET(get_url, all.headers, .domo_env$config)
  
  # handle errors
  httr::stop_for_status(get_result)
  
  if(use.dataversions.json){
    json <- httr::content(get_result, as = "parsed", type = "application/json")
    return(json)
  }else{
    #json <- httr::content(get_result, as = "text")  
    #df <- jsonlite::fromJSON(json)
    #final <- do.call(rbind, df)
    
    #json <- httr::content(get_result, as = "parsed", type = "application/json")
    #final <- data.frame(json)
    #return(final)
    
    final_result <- NULL
    
    r <- httr::content(get_result)
    num_ds <- length(r)
    
    ds_meta <- data.frame(matrix(0,nrow=num_ds,ncol=10))
    
    names(ds_meta) <- c('dataSourceId','schemaId','dataVersionId','status','statusMessage',
      'datetimeRecorded','datetimeUploadCompleted','runDurationSeconds','sizeBytes','rowCount')
    
    if (num_ds > 0) {
      for (i in 1:num_ds) {
        row <- unlist(r[[i]])
        for (j in names(ds_meta)) {
          if (is.null(row[j])) { ds_meta[i,j] <- 0 } else { ds_meta[i,j] <- row[j] }
        }
      }
    }
    
    date_vars <- c('datetimeRecorded','datetimeUploadCompleted')
    for (key in date_vars) {
      ds_meta[ , key] <- as.POSIXct(as.numeric(ds_meta[ , key])/1000,origin='1970-01-01')
    }
    
    if(is.null(final_result)){
      final_result <- data.frame(ds_meta)
    }else{
      final_result <- merge(final_result, data.frame(ds_meta), all=T)
    }
    
    return(final_result)
    
  }
}
