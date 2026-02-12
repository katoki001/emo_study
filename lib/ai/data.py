import pandas as pd
from datasets import load_dataset
import warnings
warnings.filterwarnings('ignore')

# ============================
# LOAD AND UNIFY DATASETS
# ============================

def load_all_datasets():
    """Load all available physics datasets"""
    all_dataframes = []
    
    print("Loading physics datasets...")
    
    # 1. Wikipedia Physics Corpus
    try:
        print("Loading Wikipedia Physics Corpus...")
        wiki_df = pd.read_parquet("hf://datasets/arash11/wikipedia-physics-corpus/wikipedia-physics-paragraphs--planck-labeled.parquet")
        if 'content' in wiki_df.columns:
            wiki_df['text_content'] = wiki_df['content']
        elif 'text' in wiki_df.columns:
            wiki_df['text_content'] = wiki_df['text']
        all_dataframes.append(wiki_df[['text_content']].assign(source='wikipedia_physics'))
        print(f"  Loaded {len(wiki_df)} samples")
    except Exception as e:
        print(f"  Failed to load Wikipedia Physics Corpus: {e}")
    
    # 2. ArXiv Physics
    try:
        print("Loading ArXiv Physics...")
        arxiv_ds = load_dataset("ayoubkirouane/arxiv-physics", split="train")
        arxiv_df = arxiv_ds.to_pandas()
        if 'text' in arxiv_df.columns:
            arxiv_df['text_content'] = arxiv_df['text']
        all_dataframes.append(arxiv_df[['text_content']].assign(source='arxiv_physics'))
        print(f"  Loaded {len(arxiv_df)} samples")
    except Exception as e:
        print(f"  Failed to load ArXiv Physics: {e}")
    
    # 3. Physics ScienceQA
    try:
        print("Loading Physics ScienceQA...")
        scienceqa_ds = load_dataset("AnonySub628/physics-scienceqa", split="train")
        scienceqa_df = scienceqa_ds.to_pandas()
        if 'question' in scienceqa_df.columns:
            scienceqa_df['text_content'] = scienceqa_df['question']
        all_dataframes.append(scienceqa_df[['text_content']].assign(source='physics_scienceqa'))
        print(f"  Loaded {len(scienceqa_df)} samples")
    except Exception as e:
        print(f"  Failed to load Physics ScienceQA: {e}")
    
    # 4. MMLU Physics datasets
    mmlu_configs = [
        ('high_school_physics', 'mmlu_hs_physics'),
        ('college_physics', 'mmlu_college_physics'), 
        ('conceptual_physics', 'mmlu_conceptual_physics')
    ]
    
    for config, source_name in mmlu_configs:
        try:
            print(f"Loading MMLU {config}...")
            mmlu_ds = load_dataset("cais/mmlu", config, split="test")
            mmlu_df = mmlu_ds.to_pandas()
            if 'question' in mmlu_df.columns:
                mmlu_df['text_content'] = mmlu_df['question']
            all_dataframes.append(mmlu_df[['text_content']].assign(source=source_name))
            print(f"  Loaded {len(mmlu_df)} samples")
        except Exception as e:
            print(f"  Failed to load MMLU {config}: {e}")
    
    # 5. ARC datasets
    arc_configs = [
        ('ARC-Easy', 'arc_easy'),
        ('ARC-Challenge', 'arc_challenge')
    ]
    
    for config, source_name in arc_configs:
        try:
            print(f"Loading {config}...")
            arc_ds = load_dataset("allenai/ai2_arc", config, split="train")
            arc_df = arc_ds.to_pandas()
            if 'question' in arc_df.columns:
                arc_df['text_content'] = arc_df['question']
            all_dataframes.append(arc_df[['text_content']].assign(source=source_name))
            print(f"  Loaded {len(arc_df)} samples")
        except Exception as e:
            print(f"  Failed to load {config}: {e}")
    
    # 6. OpenBookQA
    try:
        print("Loading OpenBookQA...")
        openbook_ds = load_dataset("allenai/openbookqa", split="train")
        openbook_df = openbook_ds.to_pandas()
        if 'question_stem' in openbook_df.columns:
            openbook_df['text_content'] = openbook_df['question_stem']
        all_dataframes.append(openbook_df[['text_content']].assign(source='openbookqa'))
        print(f"  Loaded {len(openbook_df)} samples")
    except Exception as e:
        print(f"  Failed to load OpenBookQA: {e}")
    
    # 7. Physics Instruct
    try:
        print("Loading Physics Instruct...")
        physics_instruct_ds = load_dataset("OpenLMLab/Physics-Instruct", split="train")
        physics_instruct_df = physics_instruct_ds.to_pandas()
        if 'instruction' in physics_instruct_df.columns:
            physics_instruct_df['text_content'] = physics_instruct_df['instruction']
        all_dataframes.append(physics_instruct_df[['text_content']].assign(source='physics_instruct'))
        print(f"  Loaded {len(physics_instruct_df)} samples")
    except Exception as e:
        print(f"  Failed to load Physics Instruct: {e}")
    
    # 8. Wikipedia Passages
    try:
        print("Loading Wikipedia Passages...")
        wiki_passages_ds = load_dataset("TIGER-Lab/Wikipedia-Passage", "physics", split="train")
        wiki_passages_df = wiki_passages_ds.to_pandas()
        if 'passage' in wiki_passages_df.columns:
            wiki_passages_df['text_content'] = wiki_passages_df['passage']
        all_dataframes.append(wiki_passages_df[['text_content']].assign(source='wikipedia_passages'))
        print(f"  Loaded {len(wiki_passages_df)} samples")
    except Exception as e:
        print(f"  Failed to load Wikipedia Passages: {e}")
    
    return all_dataframes

# ============================
# PROCESS AND SAVE DATASET
# ============================

def create_final_dataset():
    """Create and save the final physics dataset"""
    
    # Load all datasets
    dataframes = load_all_datasets()
    
    if not dataframes:
        print("No datasets were loaded successfully!")
        return None
    
    # Combine all dataframes
    print("\nCombining all datasets...")
    df_all = pd.concat(dataframes, ignore_index=True)
    print(f"Total samples before cleaning: {len(df_all)}")
    
    # Clean the data
    df_all = df_all.dropna(subset=['text_content'])
    df_all['text_content'] = df_all['text_content'].astype(str).str.strip()
    df_all = df_all[df_all['text_content'].str.len() >= 20]
    
    # Remove duplicates
    df_all = df_all.drop_duplicates(subset=['text_content']).reset_index(drop=True)
    
    # Add ID column
    df_all['id'] = range(1, len(df_all) + 1)
    
    # Reorder columns
    df_all = df_all[['id', 'text_content', 'source']]
    
    print(f"\nFinal dataset statistics:")
    print(f"Total unique samples: {len(df_all)}")
    print(f"\nSources distribution:")
    print(df_all['source'].value_counts())
    
    # Save to CSV
    output_path = "final_physics_dataset.csv"
    df_all.to_csv(output_path, index=False, encoding="utf-8")
    print(f"\nDataset saved to: {output_path}")
    
    return df_all

# ============================
# MAIN EXECUTION
# ============================

if __name__ == "__main__":
    print("Starting physics dataset creation...")
    df_final = create_final_dataset()
    
    if df_final is not None:
        print("\nFirst few rows of the dataset:")
        print(df_final.head())
        print(f"\nDataset shape: {df_final.shape}")