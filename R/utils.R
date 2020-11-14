#' run the collection functions
#' @param slack logical. whether or not to collect slack member count. defaults to TRUE
#' @param facebook logical. whether or not to collect facebook likes. defaults to TRUE
#' @param twitter logical. whether or not to collect twitter follower count. defaults to TRUE
#' @param mailchimp logical. whether or not to collect mailchimp subscriber count. defaults to TRUE
#' @description run the collector functions with their default arguments. You can pick and choose which ones you want to run.
#' @return a tibble with 3 columns: character column platform which contains the name of the platform, integer column n with the count, and date which is constant and set to today.
#' @export
collect_data <- function(slack = TRUE, facebook = TRUE, twitter = TRUE, mailchimp = TRUE) {
  df <- tibble::tibble(date = c(), platform = c(), n = c())
  if (slack) {
    slack_df <- ca_slack()
    df <- rbind(df, slack_df)
  }

  if (facebook) {
    facebook_df <- ca_facebook()
    df <- rbind(df, facebook_df)
  }

  if (twitter) {
    twitter_df <- ca_twitter()
    df <- rbind(df, twitter_df)
  }

  if (mailchimp) {
    mailchimp_df <- ca_newsletter()
    df <- rbind(df, mailchimp_df)
  }
  return(df)
}
