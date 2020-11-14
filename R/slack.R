#' get number of slack members
#' @return integer. number of CorrelAid slack members
#' @export
ca_slack <- function() {
  slackr::slackr_setup(config_file = "./.slackr")
  nrow(slackr::slackr_users())
}

