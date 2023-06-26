rule get_genome:
    output:
        genome,
    log:
        "logs/get-genome.log",
    params:
        species=config["ref"]["species"],
        datatype="dna",
        build=config["ref"]["build"],
        release=config["ref"]["release"],
        chromosome=config["ref"].get("chromosome"),
    cache: "omit-software"
    wrapper:
        "v1.2.0/bio/reference/ensembl-sequence"


rule genome_faidx:
    input:
        genome,
    output:
        genome_fai,
    log:
        "logs/genome-faidx.log",
    cache: "omit-software"
    wrapper:
        "v1.10.0/bio/samtools/faidx"


rule genome_dict:
    input:
        genome,
    output:
        genome_dict,
    log:
        "logs/samtools/create_dict.log",
    conda:
        "../envs/samtools.yaml"
    cache: "omit-software"
    shell:
        "samtools dict {input} > {output} 2> {log} "


rule get_vep_cache:
    output:
        directory("results/resources/vep/cache"),
    params:
        species=config["ref"]["species"],
        build=config["ref"]["build"],
        release=config["ref"]["release"],
    log:
        "logs/vep/cache.log",
    wrapper:
        "v1.24.0/bio/vep/cache"


rule get_vep_plugins:
    output:
        directory("results/resources/vep/plugins"),
    params:
        release=config["ref"]["release"],
    log:
        "logs/vep/plugins.log",
    wrapper:
        "v1.24.0/bio/vep/plugins"


# rule get_known_variants:
#     input:
#         # use fai to annotate contig lengths for GATK BQSR
#         fai=genome_fai,
#     output:
#         vcf="resources/variation.vcf.gz",
#     log:
#         "logs/get-known-variants.log",
#     params:
#         species=config["ref"]["species"],
#         release=config["ref"]["release"],
#         build=config["ref"]["build"],
#         type="all",
#         chromosome=config["ref"].get("chromosome"),
#     cache: "omit-software"
#     wrapper:
#         "v1.12.0/bio/reference/ensembl-variation"


# rule get_annotation_gz:
#     output:
#         "resources/annotation.gtf.gz",
#     params:
#         species=config["ref"]["species"],
#         release=config["ref"]["release"],
#         build=config["ref"]["build"],
#         flavor="",  # optional, e.g. chr_patch_hapl_scaff, see Ensembl FTP.
#     log:
#         "logs/get_annotation.log",
#     cache: "omit-software"  # save space and time with between workflow caching (see docs)
#     wrapper:
#         "v1.5.0/bio/reference/ensembl-annotation"


# rule determine_coding_regions:
#     input:
#         "resources/annotation.gtf.gz",
#     output:
#         "resources/coding_regions.bed.gz",
#     log:
#         "logs/determine_coding_regions.log",
#     cache: "omit-software"  # save space and time with between workflow caching (see docs)
#     conda:
#         "../envs/awk.yaml"
#     shell:
#         # filter for `exon` entries, but unclear how to exclude pseudogene exons...
#         """
#         ( zcat {input} | \\
#           awk 'BEGIN {{ IFS = "\\t"}} {{ if ($3 == "exon") {{ print $0 }} }}' | \\
#           grep 'transcript_biotype "protein_coding"' | \\
#           grep 'gene_biotype "protein_coding"' | \\
#           awk 'BEGIN {{ IFS = "\\t"; OFS = "\\t"}}  {{ print $1,$4-1,$5 }}' | \\
#           gzip > {output} \\
#         ) 2> {log}
#         """


# rule remove_iupac_codes:
#     input:
#         "resources/variation.vcf.gz",
#     output:
#         "resources/variation.noiupac.vcf.gz",
#     log:
#         "logs/fix-iupac-alleles.log",
#     conda:
#         "../envs/rbt.yaml"
#     cache: "omit-software"
#     shell:
#         "(rbt vcf-fix-iupac-alleles < {input} | bcftools view -Oz > {output}) 2> {log}"


# rule bwa_index:
#     input:
#         genome
#     output:
#         multiext(
#             genome,
#             ".0123",
#             ".amb",
#             ".ann",
#             ".pac",
#             ".pos_packed",
#             ".suffixarray_uint64",
#             ".suffixarray_uint64_L0_PARAMETERS",
#             ".suffixarray_uint64_L1_PARAMETERS",
#             ".suffixarray_uint64_L2_PARAMETERS"
#         )
#     log:
#         f"logs/bwa-meme_index/{genome}.log",
#     cache: True
#     threads: 8
#     wrapper:
#         "v1.14.0/bio/bwa-meme/index"


rule bwa_index:
    input:
        genome,
    output:
        multiext(
            genome,
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac",
        ),
    log:
        f"logs/bwa-mem2_index/{genome}.log",
    params:
        bwa="bwa-mem2",
    cache: True
    threads: 64
    wrapper:
        "v1.25.0/bio/bwa-memx/index"
