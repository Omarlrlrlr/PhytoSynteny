# Définis tes chemins ici
input_gff  = "/home/z800/Bureau/omar/genomes/pink_pepper/ncbi_dataset/data/GCF_029168945.1/sortie_longest_isoforms_cannabis.gff3"
output_gff = "/home/z800/Bureau/omar/genomes/pink_pepper/ncbi_dataset/data/GCF_029168945.1/annotations_pp.gff3"

def add_hm_prefix_to_mrna(gff_in, gff_out):
    with open(gff_in, "r") as fin, open(gff_out, "w") as fout:
        for line in fin:
            # Copie telle quelle est
            if line.startswith("#") or not line.strip():
                fout.write(line)
                continue

            cols = line.rstrip("\n").split("\t")
            if len(cols) < 9:
                fout.write(line)
                continue

            feature_type = cols[2].lower()
            if feature_type == "mrna":
                attrs = cols[8].split(";")
                new_attrs = []
                for attr in attrs:
                    if attr.startswith("ID=") and not attr.startswith("ID=pp_"):
                        # Remplace "ID=rna-" par "ID=pp_rna-"
                        new_attr = attr.replace("ID=rna-", "ID=pp_rna-") #LIGNE A MODIFIER POUR AUTRE APPLICATION SUR D'AUTRES FICHIERS GFF DE AUTRES GENOMES 
                        new_attrs.append(new_attr)
                    else:
                        new_attrs.append(attr)
                cols[8] = ";".join(new_attrs)
                line = "\t".join(cols) + "\n"

            fout.write(line)

if __name__ == "__main__":
    add_hm_prefix_to_mrna(input_gff, output_gff)
    print(f" Fichier créé : {output_gff}")
