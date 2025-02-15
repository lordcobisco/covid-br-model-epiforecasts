
# Packages -----------------------------------------------------------------
require(EpiNow, quietly = TRUE)
require(NCoVUtils, quietly = TRUE)
require(future, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(magrittr, quietly = TRUE)
require(data.table)
require(forecastHybrid)

require(lubridate)


# Get cases ---------------------------------------------------------------

states_ne <- c("PB", "PE", "AL", "BA", "CE", "MA", "PI", "RN", "SE")

NCoVUtils::reset_cache()

#cases <- NCoVUtils::get_brazil_regional_cases(geography = "states") %>%
#  dplyr::ungroup() %>%
#  dplyr::rename(region = state_name, region_code = state_code) %>%
#  dplyr::filter(region_code %in% states_ne)

# PB Souza e Patos
# SE Estancia e Lagarto
# Al Murici, Coruripe Palmeira dos Indios
# PI incluir Picos e São Raimundo Nonato
# CE Juazeiro do Norte e Sobral
# MA Chapadinha Barra da Corda Zé Doca Timon

cities <- c("BA-Salvador")

cases <- read.csv("brazil/covid-br-data/covid-br-ms-cities.csv") %>%
  transmute(
    region = paste(estado, municipio, sep = "-"),
    region_code = region,
    deaths = obitosNovos,
    cases = casosNovos,
    date = ymd(data)) %>%
  filter(region %in% cities)

region_codes <- cases %>%
  dplyr::select(region, region_code) %>%
  unique()

saveRDS(region_codes, "brazil/data/region_codes.rds")

cases <- cases %>%
  dplyr::select(-deaths, -region_code) %>% 
  dplyr::rename(local = cases) %>%
  dplyr::mutate(imported = 0) %>%
  tidyr::gather(key = "import_status", value = "confirm", local, imported) %>% 
  tidyr::drop_na(region)


# Shared delay ------------------------------------------------------------

delay_defs <- readRDS("delays.rds")

# Set up cores -----------------------------------------------------
if (!interactive()){
  options(future.fork.enable = TRUE)
  #options(future.fork.enable = FALSE)
}

#future::plan("multiprocess", workers = round(future::availableCores() / 3))
future::plan("multiprocess", master = "localhost", workers = round(future::availableCores() / 3))
#future::plan("sequential")


# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  delay_defs = delay_defs,
  target_folder = "brazil/cities",
  horizon = 14,
  approx_delay = TRUE,
  report_forecast = TRUE,
  forecast_model = function(y, ...){EpiSoon::forecastHybrid_model(
    y = y[max(1, length(y) - 21):length(y)],
    model_params = list(models = "aefz", weights = "equal"),
    forecast_params = list(PI.combination = "mean"), ...)}
)


# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "brazil/cities",
                         summary_dir = "brazil/cities-summary",
                         target_date = "latest",
                         region_scale = "Region")
