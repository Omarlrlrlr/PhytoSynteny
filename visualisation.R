#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(dplyr)
  library(magrittr)
  library(argparse)
  library(geneviewer)
  library(htmlwidgets)
}) 

# === Argument parser ===
parser <- ArgumentParser(description = "Visualiser un ou plusieurs clusters de gènes avec geneviewer")
parser$add_argument("--genes", required = TRUE,
                    help = "Fichier CSV contenant les gènes annotés (colonnes: gene,start,end,strand,class,cluster)")
parser$add_argument("--links", required = FALSE,
                    help = "Fichier links contenant les liens entre clusters (colonnes: gene1,gene2,cluster_pair). Optionnel.")
parser$add_argument("--output", required = TRUE,
                    help = "Fichier HTML de sortie")
parser$add_argument("--legend", required = FALSE,
                    help = "Integre une légende a la figure avec ordre (FN / PP / HM) du haut en bas
                    ecrire selon ce format --legend FN,HM,PP selon ordre des clusters a verifié depuis le fichier blocks")
parser$add_argument("--png", required = FALSE,
                    help = "Permet d'avoir une image PNG, Note: que le navigateur chrome est nécessaire pour ca")

args <- parser$parse_args()

#Légendes
titles <- NULL
if (!is.null(args$legend)) {
  titles <- unlist(strsplit(args$legend, ","))
}

# === Lecture des données ===
genes <- read.csv(args$genes, stringsAsFactors = FALSE)
if ("gene" %in% names(genes)) {
  colnames(genes)[colnames(genes) == "gene"] <- "name"
}
# === Créer le chart ===
chart <- GC_chart(
  genes,
  start = "start",
  end = "end",
  group = "class",
  height = "400px",
  width = "600px",
  cluster = "cluster"
)

# === Ajuster l’échelle uniquement pour les clusters présents ===
clusters_present <- sort(unique(genes$cluster))
for (cl in clusters_present) {
  chart <- chart %>%
    GC_scale(
      cluster = cl,
      reverse = ifelse(cl == max(clusters_present), TRUE, FALSE),
      ticksCount = 0,
      lineStyle = list(strokeWidth = 0)
    )
}

# === Ajouter les liens si fichier fourni ===
if (!is.null(args$links)) {
  links <- read.csv(args$links, stringsAsFactors = FALSE) %>%
    mutate(
      cluster1 = as.integer(sub("-.*", "", cluster_pair)),
      cluster2 = as.integer(sub(".*-", "", cluster_pair))
    )
  
  for (pair in unique(links$cluster_pair)) {
    df <- links %>% filter(cluster_pair == pair)
    chart <- chart %>%
      GC_links(
        "name",
        value1 = df$gene1,
        value2 = df$gene2,
        cluster = c(unique(df$cluster1), unique(df$cluster2))
      )
  }
}

# === Tooltips et titre ===
# chart <- chart %>%
#   GC_tooltip(formatter = "<b>Gene: </b>{name}<br><b>") %>%
#   GC_clusterTitle(
# #title = paste0("<i>", basename(args$genes), "</i>"),
#     title = c(paste0("<i>", titles, "</i>"),
#     titleFont = list(fontWeight = "normal"),
#     x = 200,
#     y = 20
#   ) %>%

if (!is.null(titles)) {
  chart <- chart %>%
    GC_clusterTitle(
      title = paste0("<i>", titles, "</i>"),
      titleFont = list(fontWeight = "normal"),
      x = 200,
      y = 20
    )
}
  chart <- chart %>%
    GC_genes(marker = "boxarrow", marker_size = "small")
  chart <- chart %>%
    GC_tooltip(formatter = "<b>Gene: </b>{name}<br><b>") 


# === Sauvegarde ===
htmlwidgets::saveWidget(chart, args$output, selfcontained = TRUE)

cat("Visualisation générée :", args$output, "\n")

# === Exporter en PNG === 
if (!is.null(args$png)) {
  if (!requireNamespace("webshot2", quietly = TRUE)) {
    stop("Le package 'webshot2' n'est pas installé. Installez-le avec install.packages('webshot2').")
  }
  webshot2::webshot(args$output, file = args$png, cliprect = "viewport")
}
