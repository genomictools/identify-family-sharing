#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { SUBSET }      from './modules/subset.nf'
include { FILL }        from './modules/fill.nf'
include { FILTER }      from './modules/filter.nf'
include { CONVERT }     from './modules/convert.nf'
include { EXTRACT }     from './modules/extract.nf'
include { SHARING }     from './modules/sharing.nf'
include { CLASSIFY }    from './modules/classify.nf'
include { ATTACH }      from './modules/attach.nf'
include { DRAW }        from './modules/draw.nf'
include { PARSE }       from './modules/parse.nf'
include { MODEL }       from './modules/model.nf'

// Define input channels
variants_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ 
        row.family, row.pheno, file(row.pedigree),
        file(row.file), file(row.index)
     ] }

category_ch = Channel.of(params.categories.split(','))
type_ch     = Channel.of(params.type.split(','))
blacklist_ch = Channel.fromPath(params.blacklist)

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
        | combine(blacklist_ch)
        | SHARING
        | groupTuple(by: [1, 2])
        | combine(type_ch)
        | CLASSIFY
        | filter { it[2] == 'variant' }
        | splitCsv(header: true, sep: '\t')
        | map { pheno, category, type, row -> [ row.famid, row.pheno, row.category, row.gene, row.variant ] }
        | distinct
        | groupTuple(by: [0, 1, 2, 3])
        | filter { it[3] == 'CDC20' || it[3] == 'MUC6' }
        | set { shared }

    // Draw pedigrees
    filtered
        | ATTACH
        | ( params.draw ? combine(shared, by: [0, 1, 2]) : map {it} )
        | ( params.draw ? DRAW : map {it} )

    // Model families
    FILTER.out
        | PARSE
        | MODEL
}
