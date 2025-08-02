#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Load subworkflow
include { summarize_sharing } from './subworkflows/summarize_sharing.nf'

// Define input channels
family_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.famid, file(row.cases), file(row.pedigree)] }
    | unique

variants_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [
        row.famid, row.category, file(row.rlist), file(row.annotation)
    ] }

blacklist_ch = Channel.fromPath(params.blacklist)

if ( params.draw ) {
to_draw = Channel.fromPath(params.draw_genes)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.famid, row.gene, row.variant ] }
    | groupTuple(by: [0, 1])
} else {
to_draw = Channel.empty()
}

// Run the main workflow
workflow  {
    summarize_sharing(variants_ch, family_ch, blacklist_ch, to_draw)
}
