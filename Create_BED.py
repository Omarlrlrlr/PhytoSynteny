#Activer manuellement environnement conda
#conda activate py

import pandas as pd

# Fichiers d’entrée
bed_file = "/home/z800/Bureau/omar/resultats/geneviewer/bed_gff/cannabis_humulus_finola.bed" #Ficheir bed crée avec "McScan" 
blocks_file = "/home/z800/Bureau/omar/resultats/geneviewer/FNc8_PPc31_HMc31/cluster8_matched_blocks_clean.txt" #Fichier blocks de clusters orthologues créer avec la méthode de "cross-reference mapping" 
gff_file = "/home/z800/Bureau/all_gff.gff" #Fichier d'annotation des 3 génomes concatener "cat finola.gff pink_pepper.gff humulus.gff > all_gff.gff"

# Charger le BED
bed = pd.read_csv(
    bed_file, sep="\t", header=None,
    names=["chrom", "start", "end", "gene", "score", "strand"]
)

# Lire les triplets (ou paires)
triplets = []
with open(blocks_file) as f:
    for line in f:
        line = line.strip()
        if line.startswith("#") or not line:
            continue
        tokens = line.split()
        if len(tokens) < 2:
            print(f"Ligne ignorée (moins de 2 colonnes) : {line}")
            continue
        while len(tokens) < 3:
            tokens.append("")  # remplir avec chaîne vide
        triplets.append((tokens[0], tokens[1], tokens[2]))

# Séparer les gènes des 3 espèces (si colonne vide, ignorée)
g1s = [t[0] for t in triplets if t[0]]
g2s = [t[1] for t in triplets if t[1]]
g3s = [t[2] for t in triplets if t[2]]

bed1 = bed[bed['gene'].isin(g1s)]
bed2 = bed[bed['gene'].isin(g2s)]
bed3 = bed[bed['gene'].isin(g3s)]

# Trouver les bornes si non vide
def get_bounds(bed_sub):
    if bed_sub.empty:
        return None, None, None
    return bed_sub['start'].min(), bed_sub['end'].max(), bed_sub['chrom'].iloc[0]

start1, end1, chrom1 = get_bounds(bed1)
start2, end2, chrom2 = get_bounds(bed2)
start3, end3, chrom3 = get_bounds(bed3)

# Extraire les gènes dans la fenêtre
def extract_cluster(chrom, start, end, cluster_num):
    if chrom is None:
        return pd.DataFrame()
    df = bed[
        (bed['chrom'] == chrom) &
        (bed['start'] >= start) &
        (bed['end'] <= end)
    ].copy()
    df['cluster'] = cluster_num
    return df

cluster1_all = extract_cluster(chrom1, start1, end1, 1)
cluster2_all = extract_cluster(chrom2, start2, end2, 2)
cluster3_all = extract_cluster(chrom3, start3, end3, 3)

# Concaténer ceux valides
final = pd.concat(
    [df for df in [cluster1_all, cluster2_all, cluster3_all] if not df.empty],
    ignore_index=True
)

# Dictionnaire ID → (annotation, strand)
annotations = {}
with open(gff_file) as gff:
    for line in gff:
        if line.startswith("#"):
            continue
        parts = line.strip().split("\t")
        if len(parts) < 9:
            continue
        if parts[2] != "mRNA":
            continue
        chrom, _, _, start, end, _, strand, _, attrs = parts
        gene_id = None
        annot = None
        for field in attrs.split(";"):
            if field.startswith("ID="):
                gene_id = field.replace("ID=", "").split(",")[0]
            if field.startswith("product=") or field.startswith("Name=") or field.startswith("description="):
                annot = field.split("=")[1]
        if gene_id:
            annotations[gene_id] = (annot if annot else "NA", strand)

# Récupérer annotation
def get_annotation_and_strand(gene_id):
    if gene_id in annotations:
        return annotations[gene_id]
    if "_" in gene_id:
        clean_id = gene_id.split("_", 1)[1]
        if clean_id in annotations:
            return annotations[clean_id]
    return ("NA", ".")

final[['class', 'strand']] = final['gene'].apply(
    lambda gid: pd.Series(get_annotation_and_strand(gid))
)

# Réordonner et sauvegarder
final = final[['gene', 'start', 'end', 'strand', 'class', 'cluster']]
final.to_csv("genes_within_3clusters_annotated.csv", index=False)

print(" Fichier `genes_within_3clusters_annotated.csv` généré.")
print(final.head())



