#' get number of slack members
#' @return integer. number of CorrelAid slack members
#' @param slackr_path character. path to .slackr file. defaults to ".slackr"
#' @return tibble
#' @export
ca_slack <- function(slackr_path = ".slackr") {
  if (!file.exists(slackr_path)) {
    stop("./.slackr does not exist.")
  }
  slackr::slackr_setup(config_file = slackr_path)
  return(tibble::tibble(date = Sys.Date(), platform = "slack", n = nrow(slackr::slackr_users())))

}

