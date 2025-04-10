#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { SUBSET }      from './modules/subset.nf'
include { FILL }        from './modules/fill.nf'
include { FILTER }      from './modules/filter.nf'
include { CONVERT }     from './modules/convert.nf'
include { SHARING }     from './modules/sharing.nf'
include { ATTACH }      from './modules/attach.nf'
include { DRAW }        from './modules/draw.nf'
include { EXTRACT }     from './modules/extract.nf'

// Define input channels
variants_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ 
        row.family, row.pheno, file(row.pedigree),
        file(row.file), file(row.index)
     ] }

category_ch = Channel.of(params.categories.split(','))
type_ch     = Channel.of(params.type.split(','))

workflow {
    // Extract families, Subset and Filter
    variants_ch
        | SUBSET
        | filter { it.last().toInteger() > 0 }
        | ( params.fill ? FILL : map {it} )
        | filter { it.last().toInteger() > 0 }
        | combine(category_ch)
        | FILTER
        | filter { it.last().toInteger() > 0}
        | CONVERT
        | set { filtered }

    // Extract variants stats
    filtered
        | EXTRACT
        | combine(type_ch)
        | SHARING
        | splitCsv(header: true, sep: '\t')
        | map { famid, pheno, category, type, row -> [ famid, pheno, category, type, row.gene, row.variant] }
        | groupTuple(by: [0, 1, 2, 3, 4])
        | distinct
        | take(3)
        | set { shared }

    // Draw pedigrees
    filtered
        | ATTACH
        | ( params.draw ? combine(shared, by: [0, 1, 2]) : map {it} )
        | ( params.draw ? DRAW : map {it} )
}
