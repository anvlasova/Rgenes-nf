#!/usr/bin/env nextflow

/*
 * Copyright (c) 2017, Centre for Genomic Regulation (CRG)
 *
 * Copyright (c) 2017, Anna Vlasova
 *
 * Copyright (c) 2017, Antonio Hermoso Pulido
 *
 * Copyright (c) 2017, Emilio Palumbo
 *
 * Functional Annotation Pipeline for protein annotation from non-model organisms 
 * from Genome Annotation Team in Catalyña (GATC) implemented in Nextflow
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


// there can be three log levels: off (no messages), info (some main messages), debug (all messages + sql queries)


// default parameters
params.help = false
params.debug="false"

//print usage
if (params.help) {
  log.info ''
  log.info 'Resistant genes annotation pipeline' 
  log.info '----------------------------------------------------'
  log.info 'Run resistance genes annotation for a given plant.'
  log.info ''
  log.info 'Usage: '
  log.info "  ./nextflow run  pipeline.nf --config main_configuration.config [options]"
  log.info ''
  log.info 'Options:'
  log.info '-resume		resume pipeline from the previous step, i.e. in case of error'
  log.info '-help		this message'
  exit 1
}


/* 
* Parse the input parameters
*/

// specie-specific parameters

protein = file(params.proteinFile)
config_file = file(params.config)

// program-specific parameters
db_name = file(params.blastDB_path).name
db_path = file(params.blastDB_path).parent

interpro = params.interproscan

// print log info

log.info ""
log.info "Functional annotation pipeline"
log.info ""
log.info "General parameters"
log.info "------------------"
log.info "Protein sequence file        : ${params.proteinFile}"


// split protein fasta file into chunks and then execute annotation for each chunk
// chanels for: interpro and blast
seqData= Channel
 .from(protein)
 .splitFasta(by: params.chunkSize)

if(params.debug=="TRUE"||params.debug=="true")
{
 println("Debugging.. only the first 2 chunks will be processed")
 (seq_file1, seq_file2) = seqData.take(2).into(2)
}
else
{
 println("Process entire dataset")
(seq_file1, seq_file2) = seqData.into(2)
}

process blast{
 input:
 file seq from seq_file1
 file db_path
 
 output: 
 file(blast) into (blast_results, blast_results2)

 """
  blastp -db $db_path/$db_name -query $seq -num_threads 8 -evalue  0.00001 -out blastXml -outfmt 5
 """
}


process ipscn {
   
    module "Java/1.8.0_74"

    input:
    file seq from seq_file2
    
    output:
    file('out') into (ipscn_result, ipscn_result2)

    """  
    sed 's/*//' $seq > tmp4ipscn
    $interpro -i tmp4ipscn --goterms --iprlookup --pathways  -o out -f TSV
    """
}

/*
Generate result files and report
*/

/*
process 'generateResultFiles'{
 input: 
  file blast from blast_results
  fiel ipscnFile from ipscn_result

 
 """
  get_results.pl -conf $config
 """
}


process 'generateReport'{
 input:

 output:

 """
 
 """

}
*/


blast_result2
  .collectFile() { item ->
       [ "${item[0]}.blast.res", item + '\n' ]
   }
  .println { "BLAST results saved to file: $it" }

ipscn_result2
  .collectFile(name: file(params.resultPath + "interProScan.res.tsv"))
  .println { "InterProScan results saved to file: $it" }
