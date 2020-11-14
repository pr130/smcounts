#' get follower count for CorrelAid twitter account
#' @param user character. Twitter user to get follower count for. Defaults to Sys.getenv("TWITTER_USER")
#' @return tibble
#' @export
ca_twitter <- function(user = Sys.getenv("TWITTER_USER")) {
  if (user == "") {
    stop("Please specify a user.")
  }
  correlaid <- rtweet::lookup_users(user)
  return(tibble::tibble(date = Sys.Date(), platform = "twitter", n = correlaid$followers_count))
}
