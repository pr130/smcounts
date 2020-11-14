smcounts
================

# Installation

When on *Raspberry Pi* / Linux, try installing the dependencies with
[{bspm}](https://github.com/Enchufa2/bspm) first. This will install the
packages as binaries instead of compiling them from source, speeding up
the installation of {smcounts} later.

``` r
install.packages("bspm")
bspm::enable()
install.packages(c("magrittr", "httr", "lubridate", "stringr", "tibble", "glue", "rtweet", "slackr", "here"))
```

Then install from GitHub using {remotes} (select “none” when it asks you
about whether you want to update packages):

``` r
remotes::install_github("friep/smcounts")
```

# Usage

After setting up the necessary authentication files (see below), you can
use {smcounts} as follows:

``` r
library(smcounts)
library(dplyr)

fb <- ca_facebook()
tw <- ca_twitter()
mc <- ca_newsletter()
sl <- ca_slack()

# bind them together
all <- bind_rows(fb, tw, mc, sl)
```

Or use `collect_data` to get all platforms (with default arguments to
the individual functions):

``` r
all <- collect_data()
```

You can turn off specific platforms (e.g. when you don’t need it or if
you need to pass custom arguments):

``` r
all_except_slack <- collect_data(slack = FALSE)
```

### helper functions

You can use `mailchimp_lists` to find out the id of the audience you
want to track:

``` r
mailchimp_lists() %>% bind_rows() %>%  as_tibble()
```

# Setup

Depending on which functions you want to use, you’ll need:

  - for slack: a `.slackr` file, see
    <https://github.com/hrbrmstr/slackr>.
  - a `.Renviron` file containing several variables:

<!-- end list -->

    MAILCHIMP_KEY="mailchimp api key"
    MAILCHIMP_LIST_ID="list id of audience"
    FB_USER_ID="your personal user id"
    FB_PAGE_ID="page id"
    FB_APP_ID="app id of app that you created in the developer portal"
    FB_APP_SECRET="app secret of app that you created in the developer portal"
    FB_PAGE_TOKEN="the never-expiring page token that you generated (see below)"

## Facebook Authentication

Facebook Authentication is a mess. Finding the page ID in the user
interface was quite hard - the UI changes constantly. Just click around
on your page and hope you’ll find it (it is not the URL part of your
page…).

This site is a good overview:
<https://developers.facebook.com/docs/pages/access-tokens>.

After a lot of digging, this is what I came up with to generate a
(hopefully) never expiring page access token:

``` r
readRenviron(".Renviron")
page_id <- Sys.getenv("FB_PAGE_ID")
app_id <- Sys.getenv("FB_APP_ID")
app_secret <- Sys.getenv("FB_APP_SECRET")

# get page access token without expiration
# first, we need a long-lived user access token - for that we need a short-lived user access token
# get a short lived user access token using the graph explorer tool https://graph.facebook.com/v9.0/
# make sure to give the page_insights permission (Category "Other")
fb_user_short_lived <- "YOUR SHORT LIVED TOKEN"
user_at_url <- glue::glue("https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id={app_id}&client_secret={app_secret}&fb_exchange_token={fb_user_short_lived}")

res <- httr::GET(user_at_url)
fb_user_long_lived <- httr::content(res, type = "application/json")$access_token

# get page accesstoken
# If you used a long-lived User access token, the Page access token has no expiration date.
page_url <- glue::glue("https://graph.facebook.com/{page_id}?fields=access_token&access_token={fb_user_long_lived}")

res <- httr::GET(page_url)
fb_page_never_expire <- content(res, type = "application/json")$access_token
fb_page_never_expire
```

Put this token into your `.Renviron` as `FB_PAGE_TOKEN`.
