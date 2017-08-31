#' Determine dataflows inputs and outputs based of dataflow datasetId
#'
#' @param outDataSourceId A data source id (GUID)
#' @param use.dataflows.json TRUE returns pretty json output
#' @export
#' @examples
#' DomoR::init(Sys.getenv('DOMO_BASE_URL'), Sys.getenv('DEVELOPER_TOKEN'))
#' DomoR::list_dataflows(outDataSourceId='d0b246-3b41', use.dataflows.json=FALSE)
list_dataflows <- function(outDataSourceId=NULL, use.dataflows.json=FALSE){

  # check that required env variables exist
  if(!exists("customer", .domo_env) || !exists("auth.token", .domo_env)) {
    stop("Both a customer instance and token are required, please set with 'DomoR::init('customer', 'token')'")
  }

  outDataSourceId_param <- ''
  if(!is.null(outDataSourceId)) {
    outDataSourceId_param <- paste0('?outDataSourceId=', outDataSourceId)
  }

  # make the request
  get_url <- paste0(.domo_env$customer.url, '/api/dataprocessing/v1/dataflows', outDataSourceId_param)

  all.headers <- httr::add_headers(c(.domo_env$auth.token, .domo_env$user.agent,
                                     'Content-Type'='application/json'))

  get_dataflow_result <- httr::GET(get_url, all.headers, .domo_env$config, nullValue=NA)

  # handle errors
  httr::stop_for_status(get_dataflow_result)

  get_result <- unlist(httr::content(get_dataflow_result,check.names=FALSE),recursive=FALSE)

  if(use.dataflows.json){
    return(get_result)
  }else{

    my_origin='1970-01-01'

    out <- data.frame(
        id=get_result$id,
        name=get_result$name,
        databaseType=get_result$databaseType,
        dapDataFlowId=get_result$dapDataFlowId,
        responsibleUserId=get_result$responsibleUserId,
        lastExecution_beginTime=as.POSIXct(as.numeric(get_result$lastExecution$beginTime)/1000, origin=my_origin),
        # lastExecution_endTime=as.POSIXct(as.numeric(get_result$lastExecution$endTime)/1000, origin=my_origin),
        lastExecution_lastUpdated=as.POSIXct(as.numeric(get_result$lastExecution$lastUpdated)/1000, origin=my_origin),
        lastExecution_state=get_result$lastExecution$state,
        created=as.POSIXct(as.numeric(get_result$created)/1000, origin=my_origin),
        modified=as.POSIXct(as.numeric(get_result$modified)/1000, origin=my_origin),
        numInputs=get_result$numInputs,
        numOutputs=get_result$numOutputs,
        executionSuccessCount=get_result$executionSuccessCount
    )

    inputs <- dplyr::bind_rows(lapply(get_result$inputs,function(x,df_id=get_result$id){
        input_out <- data.frame(
            id=df_id,
            type='input',
            ds_id=x$dataSourceId,
            ds_name=x$dataSourceName
        )
        return(input_out)
    }))

    outputs <- dplyr::bind_rows(lapply(get_result$outputs,function(x,df_id=get_result$id){
        output_out <- data.frame(
            id=df_id,
            type='output',
            ds_id=x$dataSourceId,
            ds_name=x$dataSourceName
        )
        return(output_out)
    }))

    in_out <- dplyr::bind_rows(inputs,outputs)

    out_final <- dplyr::left_join(out,in_out,by=c('id'='id'))

    return(out_final)
  }
}
