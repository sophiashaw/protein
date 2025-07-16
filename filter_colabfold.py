# filter_colabfold.py
import json
import os
import sys
from glob import glob
import pandas as pd

def avg_plddt(plddt_list):
    return sum(plddt_list) / len(plddt_list) if plddt_list else None

def get_af2_scores(af2_output_path):
    data_records = []
    files = glob(f'{af2_output_path}/*rank_1*.json')
    for file in files:
        with open(file, 'r') as f:
            data = json.load(f)

        filename = os.path.basename(file)
        design_name = filename.replace('_rank_1.json', '')

        max_pae = data.get('max_pae', None)
        plddt_list = data.get('plddt', [])
        average_plddt = avg_plddt(plddt_list)

        data_records.append({
            'design_name': design_name,
            'max_pae': max_pae,
            'average_plddt': average_plddt
        })

    return pd.DataFrame(data_records)

if __name__ == "__main__":
    af2_output_path = sys.argv[1]
    output_path = sys.argv[2]

    df = get_af2_scores(af2_output_path)
    df.to_csv(output_path, index=False)
    print(df)
