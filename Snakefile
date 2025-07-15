from glob import glob
import os

RFD_PDB_DIR = "RFD_outputs"
MPNN_SEQ_DIR = "LHD101_MPNN_outputs/seqs"
COLABFOLD_DIR = "colabfold_outputdir"

rule all:
    input:
        COLABFOLD_DIR,
        directory(MPNN_SEQ_DIR)

checkpoint run_RFD:
    input:
        "inputs/LHD101.pdb"
    output:
        directory(RFD_PDB_DIR)
    shell:
        """
        set +u
        source /opt/anaconda/anaconda3/etc/profile.d/conda.sh
        conda activate SE3nv_rmcl

        cd /home/rmcl/tools/rfdiffusion/RFdiffusion

        ./scripts/run_inference.py \
            inference.output_prefix=/home/rmcl/sopes/RFD_outputs/design_partialdiffusion \
            inference.input_pdb=/home/rmcl/sopes/inputs/LHD101.pdb \
            'contigmap.contigs=[150-150]' \
            inference.num_designs=2 \
            diffuser.partial_T=10
        """

def get_rfd_pdbs(wildcards):
    ckpt_out = checkpoints.run_RFD.get(**wildcards).output[0]
    return glob(os.path.join(ckpt_out, "*.pdb"))

rule run_MPNN:
    input:
        pdbs = get_rfd_pdbs,
        pdb_dir = RFD_PDB_DIR
    output:
        directory(MPNN_SEQ_DIR)
    shell:
        """
        set +u
        source /opt/anaconda/anaconda3/etc/profile.d/conda.sh
        conda activate rmcl-proteinmpnn

        python /home/rmcl/tools/ProteinMPNN/helper_scripts/parse_multiple_chains.py \
            --input_path={RFD_PDB_DIR} \
            --output_path=LHD101_MPNN_outputs/parsed_pdbs.jsonl

        python /home/rmcl/tools/ProteinMPNN/protein_mpnn_run.py \
            --jsonl_path LHD101_MPNN_outputs/parsed_pdbs.jsonl \
            --out_folder LHD101_MPNN_outputs \
            --num_seq_per_target 2 \
            --sampling_temp "0.1" \
            --seed 37 \
            --batch_size 1
        """

rule run_MPNN_out_to_fa:
    input:
        directory(MPNN_SEQ_DIR)
    output:
        "combined_sequences.fa"
    shell:
        """
        bash /home/rmcl/sopes/MPNN_out_to_fa.sh
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
