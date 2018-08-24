#### Jacob Albers
#### Introduction to Bioinformatics

# Takehome Project: Option 1 - Autism Variant Comparison


### Project Set-up

Directory Layout:
```
.
├── data
│   ├── 101AutismGenelistExons.bed
│   ├── autism_panel.flt.vcf
│   ├── autism_panel.raw.vcf
│   ├── autism_panel_snpEff_clinvar.vcf
│   ├── autism_panel_snpEff.vcf
│   ├── backup_pevsner_bam
│   ├── EGFR_19_DEL_EGFR_20_INS.143.vcf
│   ├── hg19.fa
│   ├── hg19.fa.fai
│   ├── proj_2.sh
│   ├── snpEff.Errors
│   ├── snpEff_genes.txt
│   ├── snpEff_summary.html
│   ├── twoBitToFa
│   ├── WebDocument_9-7_mysample1.bai
│   ├── WebDocument_9-7_mysample1.bam
│   └── WebDocument_9-7_mysample1.bam.fai
├── doc
│   ├── project_summary.md
│   ├── project_summary.md~
│   └── result_snpEff.vcf
├── snpEff_genes.txt
├── snpEff_summary.html
└── src
    ├── proj_2.sh~
    └── snpEff.Errors
```

Downloaded hg19.2bit and twoBitToFa to enable whole genome variant comparison. After `hg19.fa` was expanded, I created the additional indexing files using the `samtools faidx` command
```
[student@MSBI32400Lab4 data]$ mv ../../../home/student/Downloads/hg19.2bit .
[student@MSBI32400Lab4 data]$ mv ../../../home/student/Downloads/twoBitToFa .
[student@MSBI32400Lab4 data]$ chmod +x twoBitToFa
[student@MSBI32400Lab4 data]$ ./twoBitToFa hg19.2bit hg19.fa
[student@MSBI32400Lab4 data]$ samtools faidx hg19.fa
```

### Bash Script to Convert BAM to VCF format

In order to get Pevsner's BAM into a format with variant and other data, I built a simple script to convert the file into a number of VCF files with different amounts of additional information.

See [proj_1.sh](/data/proj_1.sh)

Script Actions:
- Call variants on `WebDocument_9-7_mysample1.bam` to `autism_panel.raw.vcf` using samtools mpileup
- Flag low quality sitess (20% threshold) of `autism_panel.raw.vcf` onto `autism_panel.flt.vcf` using bcftools
- Annotate `autism_panel.flt.vcf` into `autism_panel_snpeff.vcf` using SnpEff
- Further annotate `autism_panel_snpeff.vcf` with Clinvar data into `autism_panel_snpeff_clinar.vcf` using SnpSift

### Running VEP on VCF

Taking the un-annotated `autism_panel.flt.vcf`, I uploaded the file to VEP with the following settings:

- Ensembl & RefSeq transcripts
- Added HGVS identifiers
- Added gnomAD (exome) allele frequencies
- Include PubMed citations

A copy of the full results is viewable at [autism_panel_results.vep.txt](/results/autism_panel_results.vep.txt)


### Examining VEP output in comparison with 101 Gene List with IGV

Due to the extensive set of sites output by VEP, here are 4 sample results from VEP compared with an IGV views of the 101 Autism gene list

Note that latest frequency for Autism from the CDC is 1 in 59 children or *0.00168* (range: 13.1-29.3)

I first attempted to work from VEP and validate through IGV, this proved difficult to result in hits with the 101 Gene List:

##### Gene/Feature: 	ENSR00000000377
- **rsId:** 	rs4648659
- **Location:** 	chr1:2560903-2560903
- **Consequence:** Regulatory Region Variant
- **Biotype:** Open Chromatin Region
- **HGVSp:** 
- **Substituion:** > C
- **gnomAD allele frequency:** 0.24
- **Appearance in 101 Gene List:** No

![ENSG00000142606](/results/ENSG00000142606.png)

##### Gene/Feature: 	ENSG00000142606
- **RsId:**   
- **Location:** 
- **Consequence:** Synonymous Variant
- **Biotype:** Protein Coding
- **HGVSp:** ENSP00000367668.3:p.Pro7=
- **Substituion:** > G
- **gnomAD allele frequency:** 0.6003
- **Appearance in 101 Gene List:** No

Next I worked from IGV to identify areas in which there were matches between both the 101 Gene List and the Pevsner data

##### Gene/Feature:	DPP10
- **RsId:**   rs58524331
- **Location:** 	chr2:115219375-115219375
- **Consequence:**  5_prime_UTR_variant
- **Exon**:	1/27
- **Biotype:** Protein Coding
- **HGVSp:** N/A
- **Substituion:** > T
- **gnomAD allele frequency:** 0.02
- **Appearance in 101 Gene List:** Yes

NCBI description: This gene encodes a single-pass type II membrane protein that is a member of the S9B family in clan SC of the serine proteases. This protein has no detectable protease activity, most likely due to the absence of the conserved serine residue normally present in the catalytic domain of serine proteases. However, it does bind specific voltage-gated potassium channels and alters their expression and biophysical properties. Mutations in this gene have been associated with asthma. Alternate transcriptional splice variants, encoding different isoforms, have been characterized.

![ENSG00000142606](/results/gabrg1.png)

##### Gene/Feature: 	GABRG1
- **RsId:**   rs6447493
- **Location:** 	chr4:46042945-46042945	
- **Consequence:**   3_prime_UTR_variant		
- **Intron**:	5/8
- **Biotype:** Protein Coding
- **HGVSp:** 	ENST00000295452.4:c.60G>A
- **Substituion:** > A
- **gnomAD allele frequency:** 0.02
- **Appearance in 101 Gene List:** Yes

NCBI description: The protein encoded by this gene belongs to the ligand-gated ionic channel family. It is an integral membrane protein and plays an important role in inhibiting neurotransmission by binding to the benzodiazepine receptor and opening an integral chloride channel. This gene is clustered with three other family members on chromosome 4.

Both of these variants occurred within larger regions flagged by the 101 Gene List.

### Trimming with Pevsner BED

I also trimmed the vcf for exons using the BED file generated in Lab 3

```
samtools mpileup -B -C50 -f hg19.fa -l 101AutismGenelistExons.bed -o autism_panel.flt.vcf -v -u WebDocument_9-7_mysample1.bam
```



