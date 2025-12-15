**🌿 PhytoSynteny**

PhytoSynteny is an automated and reproducible Snakemake-based pipeline for the detection, annotation, and comparative analysis of biosynthetic gene clusters (BGCs) in plant genomes.

**📌 Overview**

PhytoSynteny provides an end-to-end workflow to identify biosynthetic gene clusters in plant genomes using PlantiSMASH, followed by downstream comparative analyses such as orthology mapping, BED file generation, and synteny-based investigations.

<img width="1150" height="373" alt="Screenshot from 2025-12-15 05-11-38" src="https://github.com/user-attachments/assets/e3a45ff8-e56c-4964-80ca-2ed5120f0cc9" />

**🔄 Pipeline Workflow**

PlantiSyn performs a complete comparative analysis of biosynthetic gene clusters across multiple plant genomes through the following steps:

***Biosynthetic gene cluster detection***
PlantiSMASH is executed on each input genome to identify and annotate biosynthetic gene clusters.

***Orthologous gene detection***
MCScan is used to detect orthologous genes and conserved genomic blocks between genomes.

***Orthologous cluster identification***
Custom scripts are applied to identify biosynthetic gene clusters that are orthologous across genomes based on gene orthology and genomic context.

***Cluster annotation and formatting***
BED-formatted files and link files are generated to describe orthologous clusters and gene-to-gene relationships.

***Visualization of synteny and orthology***
Synteny visualizations are produced using the GeneViewer library in R, enabling intuitive graphical representation of orthologous clusters and genes.


**📖 Citation**

If you use PlantiSyn in your research, please cite:

plantiSMASH 2.0: improvements to detection, annotation, and prioritization of plant biosynthetic gene clusters Elena Del Pup, Charlotte Owen, Ziqiang Luo, Hannah E. Augustijn, Arjan Draisma, Guy Polturak, Satria A. Kautsar, Anne Osbourn, Justin J.J. van der Hooft, Marnix H. Medema bioRxiv 2025.10.28.683968; doi: https://doi.org/10.1101/2025.10.28.683968
Mölder F, Jablonski KP, Letcher B et al. Sustainable data analysis with Snakemake [version 2; peer review: 2 approved]. F1000Research 2021, 10:33 (https://doi.org/10.12688/f1000research.29032.2) 
Tang H, Krishnakumar V, Zeng X, Xu Z, Taranto A, Lomas JS, Zhang Y, Huang Y, Wang Y, Yim WC, Zhang J, Zhang X. JCVI: A versatile toolkit for comparative genomics analysis. Imeta. 2024 Jun 12;3(4):e211. doi: 10.1002/imt2.211. PMID: 39135687; PMCID: PMC11316928.



