# id, overall_confidence, sequence

import pandas as pd

fasta_file = "model_4.fa"

ids = []
confidences = []
sequences = []

with open(fasta_file, "r") as f:
    lines = f.readlines()

for i in range(0, len(lines), 2):
    header = lines[i].strip()
    sequence = lines[i+1].strip()
    
    if "id=" in header:
        id_part = None
        for part in header.split(","):
            if "id=" in part:
                id_part = part
                break

        conf = None
        for part in header.split(","):
            if "overall_confidence=" in part:
                conf = part
                break
        
        if id_part and conf:
            
            id_value = id_part.split("=")[1].strip()
            confidence_value = float(conf.split("=")[1].strip())
            
            ids.append(id_value)
            confidences.append(confidence_value)
            sequences.append(sequence)

df = pd.DataFrame({
    "id": ids,
    "overall_confidence": confidences,
    "sequence": sequences
})

print(df)
