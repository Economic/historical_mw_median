ipums_extract_vars <- c(
  "YEAR", "SERIAL", "MONTH", "CPSID", "ASECFLAG", "HFLAG", "ASECWTH",
  "PERNUM", "CPSIDP", "ASECWT",
  "REGION", "STATEFIP",
  "CLASSWKR", "CLASSWLY",
  "UHRSWORKT", "UHRSWORK1", "AHRSWORKT", "UHRSWORKLY", "FULLPART",
  "WKSWORK1", "WKSWORK2",
  "INCWAGE", "AGE", "SEX", "RACE"
)

download_ipums_extract <- function() {
  # grab sample ids 
  url <- "https://cps.ipums.org/cps-action/samples/sample_ids"
  cps_sample_ids <- url %>%
    read_html() %>%
    html_table() %>%
    pluck(2) %>%
    janitor::clean_names() %>%
    filter(str_detect(description, "ASEC")) %>%
    pull(sample_id)
  
  # details on using ipumsr and IPUMS API:
  # https://cran.r-project.org/web/packages/ipumsr/vignettes/ipums-api.html
  define_extract_cps(
    description = "ASEC extract for historical median wage",
    samples = cps_sample_ids,
    variables = ipums_extract_vars
  ) %>% 
    submit_extract() %>% 
    wait_for_extract() %>% 
    download_extract("data_raw") %>%
    read_ipums_micro()
}
