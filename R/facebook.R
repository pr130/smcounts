#' get number of facebook likes
#' @param page_id integer. facebook id of the page. Defaults to environment variable FB_PAGE_ID.
#' @param access_token character. page access token that never expires. see readme how to generate it. Defaults to environment variable FB_PAGE_TOKEN.
#' @return integer. number of Facebook likes.
#' @export
ca_facebook <- function(page_id = Sys.getenv("FB_PAGE_ID"), access_token = Sys.getenv("FB_PAGE_TOKEN")) {

  if (page_id == "" | access_token == "") {
    stop("Page_id and/or access_token are not specified. Make sure to pass them directly or set them as environment variables.")
  }

  now <- Sys.time()
  today <- as.Date(now)
  yesterday <- now - lubridate::days(1)

  # hit the API
  url <- glue::glue("https://graph.facebook.com/v9.0/{page_id}/insights")
  req <- httr::GET(url, query = list(metric = "page_fans", access_token = access_token, until = as.integer(now), from = as.integer(yesterday)))
  httr::stop_for_status(req)
  # facebook gives back a paging object... find the current date!
  tmp <- httr::content(req, type = "application/json")

  # extract the end_times and find the value that corresponds to today's date
  # TODO: improve with paging in case today is not part of the initial result set.
  values <- tmp$data[[1]]$values
  end_dates <- values %>%
    lapply(function(x) return(x$end_time)) %>%
    unlist() %>%
    as.Date()
  now_ind <- which(end_dates == today)
  return(values[[now_ind]]$value)
}
