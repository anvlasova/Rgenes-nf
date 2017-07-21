# Rgenes-nf

The pipeline for resistance genes prediction and classification inplant species implemented in Nextflow engine.

[Plant Resistance Gene Database,PRG ](http://prgdb.crg.eu/wiki/Main_Page)

## Licens
The software used in this pipline is a free software for academic users. .. 


## Requirements

### Nextflow installation
The pipeline is build on Nextflow as a woking engine, so it need to be installed first

```
 wget -qO- get.nextflow.io | bash 
```
The detailed procedure is described in the [Nextflow documentation](https://www.nextflow.io/docs/latest/getstarted.html)

### Configuration file
The pipeline require as an input the configuration file with specified parameters, such as path to the input files, specie name..

The example of configuration file is included into this repository with name main_configuration.config

## Running the pipeline

The pipeline can be launched by using the following command:

```
./nextflow run pipeline.nf  --config  configuration_file.config 
```

## Pipeline parameters

#### `-resume`
This Nextflow build-in parameter allow to re-execute processes that has changed or crashed during the pipeline run. Only processes that not finished will be executed.
More information can be found in the [Nextflow documentation](https://www.nextflow.io/docs/latest/getstarted.html#modify-and-resume)
