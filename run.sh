#!/usr/bin/env bash

snakemake --profile humgen_slurm -j 64 # --rerun-triggers mtime

