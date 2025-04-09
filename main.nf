#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { PEDIGREE }    from './modules/pedigree.nf'
include { SUBSET }      from './modules/subset.nf'
include { FILTER }      from './modules/filter.nf'
include { CONVERT }     from './modules/convert.nf'
include { SHARING }     from './modules/sharing.nf'
include { ATTACH }      from './modules/attach.nf'
include { DRAW }        from './modules/draw.nf'

// Define input channels
variants_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, file(row.file), file(row.index) ] }

phenotypes_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> file(row.phenotypes) }

families_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> file(row.pedigree) }
    | splitCsv(header: true, sep: '\t')
    | map { row -> [row.famid, row.id, row.fid, row.mid, row.sex, row.aff, row.famid] }
    | groupTuple(by: 0)

category_ch = Channel.of(params.categories.split(','))
type_ch     = Channel.of(params.type.split(','))

workflow {
    // Extract families, Subset and Filter
    families_ch
        | PEDIGREE
        | combine(variants_ch)
        | SUBSET
        | combine(category_ch)
        | FILTER
        | filter { it.last().toInteger() > 0}
        | CONVERT
        | combine(type_ch)
        | SHARING
        | map { ['shared', it.last()] }
        | collectFile(keepHeader: true)
        | splitCsv(header: true, sep: '\t')
        | map { row -> [ row.famid, row.pheno, row.category, row.type, row.gene, row.variant, row.potential_pvalues, row.pvalues ] }
        // | filter { it.last().toInteger() <= params.cutoff }
        | take(5) 
        | groupTuple(by: [0,1,2,3,4])
        | set { shared }

        CONVERT.out
            | ATTACH
            | combine(shared, by: [0,1,2])
            | DRAW
}
