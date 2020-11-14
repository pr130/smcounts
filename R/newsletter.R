#' get subscriber count for CorrelAid newsletter
#' @param mc_key character. API key from mailchimp. Defaults to environment variable MAILCHIMP_KEY
#' @param mc_list_id character. id of mailchimp list / audience (extract this manually previously). Defaults to environment variable MAILCHIMP_LIST_ID
#' @description c.f. https://mailchimp.com/developer/api/marketing/lists/
#' @return tibble
#' @export
ca_newsletter <- function(mc_key = Sys.getenv("MAILCHIMP_KEY"), mc_list_id = Sys.getenv("MAILCHIMP_LIST_ID")) {
  if (mc_key == "" | mc_list_id == "") {
    stop("mc_key and/or mc_list_id are empty. Make sure to either pass them directly or set them as environment variables.")
  }
  mc_api_key <- split_api_key(mc_key)$mc_api_key
  mc_server <- split_api_key(mc_key)$mc_server

  req <- httr::GET(glue::glue("https://{mc_server}.api.mailchimp.com/3.0/lists/{mc_list_id}?fields=stats"),
                   httr::authenticate(user = "anything", password = mc_api_key))
  httr::stop_for_status(req)
  newsletter <- httr::content(req, type = "application/json")
  return(tibble::tibble(date = Sys.Date(), platform = "mailchimp", n = newsletter$stats$member_count))
}


#' helper function to get id and name of all your mailchimp lists / audiences
#' @param mc_key character. API key from mailchimp. Defaults to environment variable MAILCHIMP_KEY
#' @return list. list of all mailchimp audiences / lists including their name and id.
#' @description c.f. https://mailchimp.com/developer/api/marketing/lists/
#' @export
mailchimp_lists <- function(mc_key = Sys.getenv("MAILCHIMP_KEY"), mc_list_id = Sys.getenv("MAILCHIMP_LIST_ID")) {
  mc_api_key <- split_api_key(mc_key)$mc_api_key
  mc_server <- split_api_key(mc_key)$mc_server

  req <- httr::GET(glue::glue("https://{mc_server}.api.mailchimp.com/3.0/lists?fields=lists.name,lists.id"),
                   httr::authenticate(user = "anything", password = mc_api_key))
  all_lists <- httr::content(req, type = "application/json")
  httr::stop_for_status(req)
  all_lists
}

#' helper function to split mailchimp api key into its two components
split_api_key <- function(mc_key) {
  # two parts to the API key - the actual key which serves as a password and the server prefix (e.g. us12)
  tmp <- unlist(stringr::str_split(mc_key, pattern = "-"))
  list(mc_api_key = tmp[1], mc_server = tmp[2])
}
