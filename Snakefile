from glob import glob
import os

MPNN_SEQ_DIR = "LHD101_MPNN_outputs/seqs"
COLABFOLD_DIR = "colabfold_outputdir"
folder_with_pdbs="/home/rmcl/sopes/inputs"

rule all:
    input:
        "colabfold_filtered.csv",
        COLABFOLD_DIR,
        MPNN_SEQ_DIR

rule run_MPNN:
    input:
        "bias_by_res_full.json"
    output:
        directory(MPNN_SEQ_DIR)
    shell:
        """
        set +u
        source /opt/anaconda/anaconda3/etc/profile.d/conda.sh
        conda activate rmcl-proteinmpnn
        
        
        python /home/rmcl/tools/ProteinMPNN/helper_scripts/parse_multiple_chains.py \
            --input_path={folder_with_pdbs} \
            --output_path=LHD101_MPNN_outputs/parsed_pdbs.jsonl
        
        python /home/rmcl/tools/ProteinMPNN/protein_mpnn_run.py \
                --jsonl_path LHD101_MPNN_outputs/parsed_pdbs.jsonl \
                --bias_by_res_jsonl /home/rmcl/sopes/bias_by_res_full.jsonl \
                --out_folder LHD101_MPNN_outputs \
                --num_seq_per_target 1000 \
                --sampling_temp "1.0" \
                --batch_size 1
        """

rule run_MPNN_out_to_fa:
    input:
        MPNN_SEQ_DIR
    output:
        "combined_sequences.fa"
    shell:
        """
        python /home/rmcl/sopes/MPNN_out_to_fa.py
        """

rule run_colabfold:
    input:
        "combined_sequences.fa"
    output:
        directory(COLABFOLD_DIR)
    shell:
        """
        set +u
        source /opt/anaconda/anaconda3/etc/profile.d/conda.sh
        conda activate alphafold_rmcl
        colabfold_batch --msa-mode single_sequence --num-recycle 3 {input} {output}
        """

rule analyze_colabfold_output:
    input:
        af2_output_path = COLABFOLD_DIR
    output:
        "colabfold_filtered.csv"
    shell:
        """
        python filter_colabfold.py {input.af2_output_path} {output}
        """
