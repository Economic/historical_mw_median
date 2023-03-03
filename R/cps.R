


asec_hours_ftpt <- function(asec_raw) {
  asec_raw %>% 
    janitor::clean_names() %>% 
    filter(
      age >= 16,
      classwkr == 21 | classwkr == 24,
      ahrsworkt > 0 & ahrsworkt < 999,
      asecwt > 0
    ) %>%
    mutate(full_time = case_when(
      ahrsworkt < 35 ~ 0,
      ahrsworkt >= 35 ~ 1
    )) %>%
    summarize(
      hours_actual_avg = weighted.mean(ahrsworkt, w = asecwt),
      .by = c(year, full_time)
    )
}

clean_asec <- function(df) {
  
  hours_ftpt_year <- asec_hours_ftpt(df)
  
  df %>% 
    janitor::clean_names() %>% 
    # align last year's responses with calendar year
    mutate(year = year - 1) %>%
    filter(
      # positive wage income
      incwage > 0 & incwage < 99999998,
      # public or private employee class
      classwly %in% c(22, 25, 27, 28),
      # dropping relatively small number of cases with zero/negative weights
      asecwt > 0,
      # stick to 16+
      age >= 16
    ) %>%
    mutate(weeks_intervalled = case_when(
      wkswork2 == 1 ~ (1  + 13) / 2,
      wkswork2 == 2 ~ (14 + 26) / 2,
      wkswork2 == 3 ~ (27 + 39) / 2,
      wkswork2 == 4 ~ (40 + 47) / 2,
      wkswork2 == 5 ~ (48 + 49) / 2,
      wkswork2 == 6 ~ (50 + 52) / 2
    )) %>%
    mutate(weeks_continuous = ifelse(wkswork1 == 0, NA, wkswork1)) %>%
    mutate(full_time = case_when(
      fullpart == 1 ~ 1,
      fullpart == 2 ~ 0
    )) %>%
    left_join(hours_ftpt_year, by = c("year", "full_time")) %>%
    mutate(hours_usual = ifelse(uhrsworkly <= 99, uhrsworkly, NA)) %>%
    mutate(
      wage_int_usual = incwage / (weeks_intervalled * hours_usual),
      wage_con_usual = incwage / (weeks_continuous * hours_usual),
      # averaged hours based on FTPT averages
      wage_int_actual = incwage / (weeks_intervalled * hours_actual_avg),
    )
}

median_by_year <- function(data, var, w) {
  data %>%
    filter(!is.na(.data[[var]])) %>%
    summarize(
      value = MetricsWeighted::weighted_median(.data[[var]], w = .data[[w]]),
      .by = year
    ) %>%
    mutate(wage_var = var)
}

clean_org <- function() {
  epiextractr::load_org(1994:2022, year, orgwgt, wageotc)
}

create_historical_kaitz <- function(df, fed_mw_data, org_data) {
  
  org_median <- median_by_year(org_data, "wageotc", w = "orgwgt")
  
  asec_wage_vars <- df %>%
    colnames() %>%
    str_subset("wage_")
  
  map_dfr(asec_wage_vars, ~ median_by_year(df, .x, w = "asecwt")) %>%
    bind_rows(org_median) %>% 
    left_join(fed_mw_data, by = "year") %>% 
    mutate(value = fed_min_wage / value)
}