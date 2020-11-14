#' run the collection functions
#' @param slack logical. whether or not to collect slack member count. defaults to TRUE
#' @param facebook logical. whether or not to collect facebook likes. defaults to TRUE
#' @param twitter logical. whether or not to collect twitter follower count. defaults to TRUE
#' @param mailchimp logical. whether or not to collect mailchimp subscriber count. defaults to TRUE
#' @description run the collector functions with their default arguments. You can pick and choose which ones you want to run.
#' @return a tibble with 3 columns: character column platform which contains the name of the platform, integer column n with the count, and date which is constant and set to today.
#' @export
collect_data <- function(slack = TRUE, facebook = TRUE, twitter = TRUE, mailchimp = TRUE) {
  df <- tibble::tibble(platform = c(), n = c())
  if (slack) {
    slack_count <- ca_slack()
    df <- tibble::add_row(df, platform = "slack", n = slack_count)
  }

  if (facebook) {
    facebook_count <- ca_facebook()
    df <- tibble::add_row(df, platform = "facebook", n = facebook_count)
  }

  if (twitter) {
    twitter_count <- ca_twitter()
    df <- tibble::add_row(df, platform = "twitter", n = twitter_count)
  }

  if (mailchimp) {
    mailchimp_count <- ca_newsletter()
    df <- tibble::add_row(df, platform = "newsletter", n = mailchimp_count)
  }
  df$date <- Sys.Date()
  return(df)
}

export_to_json <- function(df, path) {
  j <- df %>% jsonlite::toJSON(pretty = TRUE)
  jsonlite::write_json(df, path)
}
