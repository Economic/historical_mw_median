create_fed_mw_annual <- function(csv) {
  read_csv(csv) %>%
    mutate(year = year(mdy(date))) %>%
    select(year, fed_min_wage) %>%
    add_row(year = 2023, fed_min_wage = 7.25) %>%
    as_tsibble(index = year) %>%
    fill_gaps() %>%
    arrange(year) %>%
    fill(fed_min_wage, .direction = "down") %>%
    as_tibble()
}
