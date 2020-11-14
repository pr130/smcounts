README
================

## Setup

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

### Facebook Authentication

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
fb_user_short_lived <- "EAAFRLE6zV1UBADjIqUhjGs7yweHf49GA0ulEZAQuXqt0SOCjnWWzpQWyhrp4mwy6IswBkCPQnQxyacJh4qI5dsTNsI2aK2ZBHOpOIxZCNm3yvU0Ys5YBk9XIY32yG0C6ZAosINqNIeSbk0a0wRGN7Lj7mO04x4Y6EjcZBwn93KZAkWA9pjC2jZALr5rQESTujI4bF6q8gxzhdNUAXZCFBygMz58reeIhLPgZD"
user_at_url <- glue::glue("https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id={app_id}&client_secret={app_secret}&fb_exchange_token={fb_user_short_lived}")

res <- httr::GET(user_at_url)
fb_user_long_lived <- content(res, type = "application/json")$access_token


# get page accesstoken
# If you used a long-lived User access token, the Page access token has no expiration date.
page_url <- glue::glue("https://graph.facebook.com/{page_id}?fields=access_token&access_token={fb_user_long_lived}")

res <- httr::GET(page_url)
fb_page_never_expire <- content(res, type = "application/json")$access_token
fb_page_never_expire
```

Put this token into your `.Renviron` as `FB_PAGE_TOKEN`.