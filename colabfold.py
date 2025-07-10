import json
import os
from glob import glob
import pandas as pd

def avg_plddt(plddt_list):
    return sum(plddt_list)/len(plddt_list) 

def get_af2_scores(af2_output_path):
    data_records = []

    files = glob(f'{af2_output_path}/*rank_1*.json')
    for file in files:
        with open(file, 'r') as f:
            data = json.load(f)

        filename = os.path.basename(files[0])
        design_name = filename.split('_')[0]

        max_pae = data.get('max_pae', None)
        plddt_list = data.get('plddt', [])

        average_plddt = avg_plddt(plddt_list)

        data_records.append({
            'design_name': design_name,
            'max_pae': max_pae,
            'average_plddt': average_plddt
        })

    df = pd.DataFrame(data_records)
    return df

af2_output_path = '/Users/rmcl/Documents/PhD/development/karly_rotation/job-runs/LHD101-10ang-af2-top-candidates-2025-1-7-24/output'
df = get_af2_scores(af2_output_path)