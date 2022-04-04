# microarray-eval-nf

A nextflow pipeline to test imputation quality of simulated microarrays.

## Development
```
git clone https://github.com/seppinho/microarray-eval-nf
cd microarray-eval-nf
docker build -t genepi/microarray-eval:latest . # don't ignore the dot
nextflow run main.nf -profile test --imputation_token <token>
```

## Run Test Job
```
nextflow run main.nf -profile test --imputation_token <token>
```
