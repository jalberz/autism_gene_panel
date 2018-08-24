#!/bin/bash
set -e
set -u
set -o pipefail

echo convert bam file to vcf and then annotate
samtools mpileup -uf ./hg19.fa ./WebDocument_9-7_mysample1.bam | bcftools call -mv > ./autism_panel.raw.vcf
bcftools filter -s LowQual -e '%QUAL<20' autism_panel.raw.vcf > autism_panel.flt.vcf
java -Xmx2G -jar /data/snpEff/snpEff.jar eff -canon -noLog hg19 autism_panel.flt.vcf > autism_panel_snpEff.vcf 
java -Xmx2G -jar /data/snpEff/SnpSift.jar annotate -noLog /data/snpEff/data/hg19/clinvar/clinvar_20180701.vcf.gz autism_panel_snpEff.vcf > autism_panel_snpEff_clinvar.vcf \
 2>> snpEff.Errors ;
  
