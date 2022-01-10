social(
  input_poster = here::here("assets/poster.Rmd"),
  input_announcement = here::here("assets/announcement.Rmd"),
  output = here::here("meetups/2022-XX-XX"),
  rmd_params = list(
    title = "Title",
    subtitle = "Subtitle",
    author = "Lille & Tunis",
    institute = "R User Groups",
    date = "Lundi 1 Janvier 2022 - 18:00 CET",
    picture = here::here("assets/user-solid.svg"),
    website = NULL,
    date_short = "2022-01-01",
    abstract = "Résumé",
    biography = "Biographie",
    survey_url = ""
  )
)
