min_lag_lotek_glatos <- function (det) 
{
  
  
  
  dtc <- data.table::as.data.table(det)
  dtc[, `:=`(ord, 1:.N)]
  data.table::setkey(dtc, transmitter_codespace, transmitter_id, 
                     receiver_sn, detection_timestamp_utc)
  dtc[, `:=`(min_lag, pmin(diff(c(NA, as.numeric(detection_timestamp_utc))), 
                           diff(c(as.numeric(detection_timestamp_utc), NA)), na.rm = TRUE)), 
      by = c("transmitter_codespace", "transmitter_id", "receiver_sn")]
  setkey(dtc, ord)
  drop_cols <- "ord"
  dtc <- dtc[, !drop_cols, with = FALSE]
  if (inherits(det, "data.table")) 
    return(dtc)
  if (inherits(det, "tbl")) 
    return(tibble::as_tibble(dtc))
  return(as.data.frame(dtc))
}
