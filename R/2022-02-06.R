abstract_text <- paste(
  "Envie de partager vos plus beaux projets R ? Le package shiny permet de développer très facilement des applications web à partir de R. Grâce à cette librairie, et d'autres librairies R dédiées à la réalisation de graphiques, il est ainsi possible de générer des tableaux de bord, introduisant même des méthodes statistiques approfondies.",
  "{shiny} est à l'heure actuelle un \"must-know\" du \"R World\".",
  "Vous souhaitez construire un application Shiny en suivant les meilleures pratiques de développement ? Alors le package {golem} est ce qu'il vous faut.",
  sep = "\n"
)
bio_text <- paste(
  "Mohamed Fodil est un instructeur certifié de R Studio. Il a obtenu un doctorat en économie.",
  "Fodil est l'auteur de deux packages R : ralger pour faciliter le scraping web et BARIS pour travailler avec l'API du portail français de données ouvertes.",
  "Il aime partager ses connaissances en science des données par le biais d'activités d'enseignement, et son package R préféré est {ggplot2}.",
  sep = "  \n"
)
social(
  output = here::here("meetups/2022-02-06"),
  rmd_params = list(
    title = "DA la Découverte de la Création des Applications R Shiny",
    subtitle = "",
    author = "Mohamed El Fodil Ihaddaden, *Ph.D.* In Economics",
    institute = "Data Scientist, R et Shiny Developer",
    date = "Dimanche 6 Février 2022 - 18:00 CET",
    picture = "https://ihaddadenfodil.com/authors/admin/avatar_huc09fd31ce9bb786d1041f70ffa59556f_325132_250x250_fill_q90_lanczos_center.jpg",
    website = "[ihaddadenfodil.com](https://ihaddadenfodil.com)",
    date_short = "2022-02-06",
    abstract = abstract_text,
    biography = bio_text,
    survey_url = "464fn7x5"
  )
)
