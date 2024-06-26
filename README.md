[![CI Tests](https://github.com/genepi/microarray-eval-nf/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/genepi/microarray-eval-nf/actions/workflows/ci-tests.yml)
[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://github.com/askimed/nf-test)

# microarray-eval-nf

A nextflow pipeline to test imputation quality of simulated microarrays.

## Development
```
git clone https://github.com/seppinho/microarray-eval-nf
cd microarray-eval-nf
docker build -t genepi/microarray-eval:latest . # don't ignore the dot
```

## Run Chip Simulation
This command simulates array data from sequencing data. For each strand file included, an array will be created. 
```
nextflow run main.nf -c tests/simulate_hg19.config -profile development
```

## Run RSQ Calculation
This command calculates the RSQ between sequencing data and imputed data. 
```
nextflow run main.nf -c tests/calc_rsq_hg19.config -profile development
```

## Run Tests
````
./nf-test test
