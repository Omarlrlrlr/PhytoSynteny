from collections import defaultdict

# Fichiers d'entrée et sortie
input_gff = "/home/z800/Bureau/omar/genomes/Humulus_lupulus_GCF_963169125.1/ncbi_dataset/data/GCF_963169125.1/genomic.gff"
output_gff = "/home/z800/Bureau/omar/genomes/Humulus_lupulus_GCF_963169125.1/ncbi_dataset/data/GCF_963169125.1/longest_only.gff3"

# Dictionnaires pour stocker les infos
gene_to_mrnas = defaultdict(list)      
mrna_to_exons = defaultdict(list)      
mrna_to_parent = {}                   

# Première etape : collecter mRNA et leurs exons
with open(input_gff) as f:
    for line in f:
        if line.startswith("#") or line.strip() == "":
            continue
        parts = line.strip().split("\t")
        if len(parts) < 9:
            continue
        feature = parts[2]
        start, end = int(parts[3]), int(parts[4])
        attr = parts[8]

        attrs = dict(x.split("=") for x in attr.split(";") if "=" in x)

        if feature == "mRNA":
            mrna_id = attrs.get("ID")
            parent_id = attrs.get("Parent")
            if mrna_id and parent_id:
                mrna_to_parent[mrna_id] = parent_id

        elif feature in ["exon", "CDS"]:
            parent = attrs.get("Parent")
            if parent:
                mrna_to_exons[parent].append((start, end))

# Calculer la longueur de chaque mRNA
for mrna, exons in mrna_to_exons.items():
    length = sum(e - s + 1 for s, e in exons)
    gene = mrna_to_parent.get(mrna)
    if gene:
        gene_to_mrnas[gene].append( (length, mrna) )

# Trouver le plus long mRNA par gène
longest_mrnas = set()
for gene, mrna_list in gene_to_mrnas.items():
    longest = max(mrna_list, key=lambda x: x[0])
    longest_mrnas.add(longest[1])

# Deuxième etape : écrire les lignes du GFF correspondant
with open(output_gff, "w") as out, open(input_gff) as f:
    write = False
    for line in f:
        if line.startswith("#") or line.strip() == "":
            out.write(line)
            continue

        parts = line.strip().split("\t")
        if len(parts) < 9:
            continue
        feature = parts[2]
        attr = parts[8]
        attrs = dict(x.split("=") for x in attr.split(";") if "=" in x)

        if feature == "gene":
            out.write(line)  # toujours garder les gènes
            continue

        if feature == "mRNA":
            mrna_id = attrs.get("ID")
            if mrna_id in longest_mrnas:
                write = True
                out.write(line)
            else:
                write = False
            continue

        if write:  # pour exons/CDS/etc
            out.write(line)

print(f"GFF avec les plus longs isoformes écrit dans : {output_gff}")

