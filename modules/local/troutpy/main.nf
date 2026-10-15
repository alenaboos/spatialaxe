process TROUTPY {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/biocontainers/YOUR-TOOL-HERE' }"

    input:
    tuple val(meta), path(spatialdata, stageAs: "input/*")

    output:
    tuple val(meta), path("${prefix}.zarr"), emit: spatialdata
    tuple val(meta), path("report/troutpy"), emit: report
    tuple val("${task.process}"), val('troutpy'),
        eval("python -c \"import importlib.metadata as m; print(m.version('troutpy'))\""),
        topic: versions, emit: versions_troutpy

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    troutpy_urna.py \\
        --input ${spatialdata} \\
        --output-zarr ${prefix}.zarr \\
        --plots-dir report/troutpy/plots \\
        --tables-dir report/troutpy/tables \\
        ${args}
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p ${prefix}.zarr report/troutpy/plots report/troutpy/tables
    touch ${prefix}.zarr/.zgroup
    touch report/troutpy/plots/.stub
    touch report/troutpy/tables/.stub
    """
}
