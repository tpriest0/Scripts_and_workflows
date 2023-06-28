#!/bin/bash

# Download KEGG database structure in txt format
wget https://www.genome.jp/kegg-bin/download_htext?htext=ko00001.keg

# Rename downloaded file
mv download_htext\?htext\=ko00001.keg KEGG_structure.txt

# Reformat the file to generate a four column output containing highest level of KEGG categories
# along with the metabolic categories associated with each 
cat KEGG_structure.txt | sed '1,5d' | sed 's/ //' | sed 's/  //' | sed 's/  //' | \
awk 'BEGIN{FS="\t";OFS=" "}{if ($1 ~ /^B/) print "B%%%",$1; else if ($1 ~ /^C/) print "C%%%",$1; else if ($1 ~ /^D/) print "D%%%",$1}' | \
tr '\n' '\t' | sed 's/B%%%/\nB%%%/g' | awk '{FS=OFS="\t"}{for (i = 1; i <= NF; i++) {if ($i ~ /C%%%/) print $1, $i} }' | \
sed 's/B%%% B //' | sed 's/C%%% C /map/' | awk 'BEGIN{FS=OFS="\t"}{sub(" ","\t",$2)}1' | sed 's/ /\t/' > KEGG_categories_to_metabolisms.txt

# Reformat the file to generate a four column output containing metabolism categories to gene IDs (K0 numbers) and descriptions
cat KEGG_structure.txt | sed '1,5d' | sed 's/ //' | sed 's/  //' | sed 's/  //' | \
awk 'BEGIN{FS="\t";OFS=" "}{if ($1 ~ /^B/) print "B%%%",$1; else if ($1 ~ /^C/) print "C%%%",$1; else if ($1 ~ /^D/) print "D%%%",$1}' | \
grep -v '^B%%%' | tr '\n' '\t' | sed 's/C%%%/\nC%%%/g' | awk '{FS=OFS="\t"}{for (i = 1; i <= NF; i++) {if ($i ~ /D%%%/) print $1, $i} }' | \
sed 's/C%%% C /map/' | sed 's/D%%% D //' | awk 'BEGIN{FS=OFS="\t"}{sub(" ","\t",$2)}1' | sed 's/ /\t/' > KEGG_metabolisms_to_ko_and_descriptions.txt

# Combine the above two files to map the KEGG categories to metabolism to genes
awk 'BEGIN{FS=OFS="\t"}FNR==NR{a[$3]=$1"\t"$2"\t"$3"\t"$4;next}{if ($1 in a) print a[$1],$3,$4}' \
KEGG_categories_to_metabolisms.txt KEGG_metabolisms_to_ko_and_descriptions.txt | \
sed '1i Category_ID\tCategory_Name\tMetabolism_ID\tMetabolism_Name\tGene_ID\tGene_Name' > KEGG_categories_to_metabolisms_to_genes.txt

