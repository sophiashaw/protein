import json
import os
from glob import glob
import pandas as pd

def avg_plddt(plddt_list):
    return sum(plddt_list)/len(plddt_list) 

def main():
    data_records = []

    cur_dir = os.path.dirname(os.path.abspath(__file__))
    print("Current directory:", cur_dir)

    files = glob(os.path.join(cur_dir, '*rank_1*.json'))

    for file in files:
        with open(file, 'r') as f:
            data = json.load(f)

        design_name = os.path.basename(cur_dir)

        max_pae = data.get('max_pae', None)
        plddt_list = data.get('plddt', [])

        average_plddt = avg_plddt(plddt_list)

        data_records.append({
            'design_name': design_name,
            'max_pae': max_pae,
            'average_plddt': average_plddt
        })

    df = pd.DataFrame(data_records)
    print(df)

if __name__ == "__main__":
    main()
