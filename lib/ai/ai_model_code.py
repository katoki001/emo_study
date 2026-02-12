import pandas as pd
from transformers import AutoTokenizer, AutoModel
import torch
import torch.nn.functional as F
import os

def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[0]
    mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * mask_expanded, 1) / torch.clamp(mask_expanded.sum(1), min=1e-9)

def generate_embeddings():
    # Check if dataset exists
    dataset_path = "final_physics_dataset.csv"
    
    if not os.path.exists(dataset_path):
        print(f"Error: Dataset file '{dataset_path}' not found!")
        print("Please run the data.py script first to create the dataset.")
        return
    
    # 1. Load CSV
    print("Loading dataset...")
    df = pd.read_csv(dataset_path)
    
    # 2. Take the text column for embeddings
    sentences = df["text_content"].tolist()
    print(f"Generating embeddings for {len(sentences)} sentences...")
    
    # 3. Load model
    print("Loading model...")
    tokenizer = AutoTokenizer.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
    model = AutoModel.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
    
    # Set model to evaluation mode
    model.eval()
    
    # 4. Process in batches to avoid memory issues
    batch_size = 45
    embeddings_list = []
    
    for i in range(0, len(sentences), batch_size):
        batch_sentences = sentences[i:i + batch_size]
        
        # Tokenize
        encoded = tokenizer(
            batch_sentences, 
            padding=True, 
            truncation=True, 
            max_length=512, 
            return_tensors="pt"
        )
        
        # Compute embeddings
        with torch.no_grad():
            output = model(**encoded)
        
        batch_embeddings = mean_pooling(output, encoded["attention_mask"])
        batch_embeddings = F.normalize(batch_embeddings, p=2, dim=1)
        
        embeddings_list.append(batch_embeddings)
        
        if i % (batch_size * 10) == 0:
            print(f"Processed {min(i + batch_size, len(sentences))}/{len(sentences)} sentences...")
    
    # Concatenate all embeddings
    embeddings = torch.cat(embeddings_list, dim=0)
    
    print(f"\nEmbeddings shape: {embeddings.shape}")
    print(f"First embedding sample (first 10 dimensions):\n{embeddings[0][:10]}")
    
    # Save embeddings for later use
    torch.save(embeddings, "physics_embeddings.pt")
    print("Embeddings saved to physics_embeddings.pt")
    
    # Also save the embeddings along with the original data
    df_embeddings = df.copy()
    df_embeddings['embedding'] = embeddings.tolist()
    df_embeddings.to_csv("physics_dataset_with_embeddings.csv", index=False)
    print("Dataset with embeddings saved to physics_dataset_with_embeddings.csv")

# ============================
# MAIN EXECUTION
# ============================

if __name__ == "__main__":
    print("Starting embedding generation...")
    generate_embeddings()