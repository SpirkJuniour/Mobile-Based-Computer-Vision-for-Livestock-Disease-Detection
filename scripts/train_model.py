#!/usr/bin/env python3
"""
Livestock Disease Detection Model Training Script

This script processes the training data and trains a model for livestock disease detection.
"""

import os
import pandas as pd
import numpy as np
from PIL import Image
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import torchvision.transforms as transforms
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import json

class LivestockDataset(Dataset):
    """Custom dataset for livestock disease images"""
    
    def __init__(self, image_paths, labels, transform=None):
        self.image_paths = image_paths
        self.labels = labels
        self.transform = transform
    
    def __len__(self):
        return len(self.image_paths)
    
    def __getitem__(self, idx):
        image_path = self.image_paths[idx]
        image = Image.open(image_path).convert('RGB')
        label = self.labels[idx]
        
        if self.transform:
            image = self.transform(image)
        
        return image, label

class DiseaseClassifier(nn.Module):
    """CNN model for disease classification"""
    
    def __init__(self, num_classes=5):
        super(DiseaseClassifier, self).__init__()
        
        # Use pre-trained ResNet as backbone
        self.backbone = torch.hub.load('pytorch/vision', 'resnet18', pretrained=True)
        
        # Replace the final layer
        num_features = self.backbone.fc.in_features
        self.backbone.fc = nn.Linear(num_features, num_classes)
        
        # Add dropout for regularization
        self.dropout = nn.Dropout(0.5)
        
    def forward(self, x):
        x = self.backbone(x)
        x = self.dropout(x)
        return x

def load_and_process_data(data_dir):
    """Load and process the training data"""
    
    # Define disease mapping - simplified to 5 main categories
    disease_mapping = {
        'lumpy_skin': 0,
        'fmd': 1, 
        'mastitis': 2,
        'healthy': 3,
        'dermatitis': 4
    }
    
    image_paths = []
    labels = []
    
    print(f"Loading data from: {data_dir}")
    
    # Process multiclass dataset
    multiclass_dir = os.path.join(data_dir, 'cattle diseases.v2i.multiclass')
    if os.path.exists(multiclass_dir):
        print("Processing multiclass dataset...")
        for split in ['train', 'valid', 'test']:
            split_dir = os.path.join(multiclass_dir, split)
            if os.path.exists(split_dir):
                csv_file = os.path.join(split_dir, '_classes.csv')
                if os.path.exists(csv_file):
                    try:
                        df = pd.read_csv(csv_file)
                        print(f"  {split}: {len(df)} images")
                        
                        for _, row in df.iterrows():
                            image_path = os.path.join(split_dir, row['filename'])
                            if os.path.exists(image_path):
                                # Determine label based on CSV columns
                                if row.get('healthy', 0) == 1:
                                    label = disease_mapping['healthy']
                                elif row.get('lumpy', 0) == 1 and row.get('skin', 0) == 1:
                                    label = disease_mapping['lumpy_skin']
                                elif row.get('Bovine', 0) == 1:
                                    label = disease_mapping['fmd']
                                elif row.get('Disease', 0) == 1:
                                    label = disease_mapping['dermatitis']
                                else:
                                    label = disease_mapping['healthy']
                                
                                image_paths.append(image_path)
                                labels.append(label)
                    except Exception as e:
                        print(f"Error processing {split}: {e}")
    
    # Process YOLO dataset - parse labels from txt files
    yolo_dir = os.path.join(data_dir, 'cattle diseases.v2i.yolov11')
    if os.path.exists(yolo_dir):
        print("Processing YOLO dataset...")
        for split in ['train', 'valid', 'test']:
            split_dir = os.path.join(yolo_dir, split)
            if os.path.exists(split_dir):
                image_count = 0
                for image_file in os.listdir(split_dir):
                    if image_file.endswith('.jpg'):
                        image_path = os.path.join(split_dir, image_file)
                        txt_file = os.path.join(split_dir, image_file.replace('.jpg', '.txt'))
                        
                        # Try to parse YOLO label file
                        label = disease_mapping['healthy']  # Default
                        if os.path.exists(txt_file):
                            try:
                                with open(txt_file, 'r') as f:
                                    lines = f.readlines()
                                    if lines:
                                        # YOLO format: class_id x_center y_center width height
                                        class_id = int(lines[0].split()[0])
                                        # Map YOLO class IDs to our categories
                                        if class_id == 0:  # Bovine FDM
                                            label = disease_mapping['fmd']
                                        elif class_id == 1:  # Bovine Mastitis
                                            label = disease_mapping['mastitis']
                                        elif class_id == 2:  # lumpy skin
                                            label = disease_mapping['lumpy_skin']
                                        elif class_id == 3:  # bacterial-dermatosis
                                            label = disease_mapping['dermatitis']
                                        elif class_id == 4:  # fungal-infection
                                            label = disease_mapping['dermatitis']
                                        elif class_id == 5:  # hypersensitivity-allergic-dermatosis
                                            label = disease_mapping['dermatitis']
                                        elif class_id == 6:  # pinkeye
                                            label = disease_mapping['dermatitis']
                                        elif class_id == 7:  # sehat (healthy)
                                            label = disease_mapping['healthy']
                                        elif class_id == 8:  # Healthy Canis
                                            label = disease_mapping['healthy']
                            except Exception as e:
                                print(f"Error parsing {txt_file}: {e}")
                        
                        image_paths.append(image_path)
                        labels.append(label)
                        image_count += 1
                
                print(f"  {split}: {image_count} images")
    
    # Process augmented datasets
    for aug_dir in ['hcaugmented', 'lcaugmented']:
        aug_path = os.path.join(data_dir, aug_dir)
        if os.path.exists(aug_path):
            print(f"Processing {aug_dir} dataset...")
            aug_count = 0
            for image_file in os.listdir(aug_path):
                if image_file.endswith('.jpg'):
                    image_path = os.path.join(aug_path, image_file)
                    # Assign labels based on directory name
                    if 'hc' in aug_dir.lower():  # Healthy Cattle
                        label = disease_mapping['healthy']
                    elif 'lc' in aug_dir.lower():  # Lumpy Cattle
                        label = disease_mapping['lumpy_skin']
                    else:
                        label = disease_mapping['healthy']
                    
                    image_paths.append(image_path)
                    labels.append(label)
                    aug_count += 1
            print(f"  {aug_dir}: {aug_count} images")
    
    print(f"Total loaded: {len(image_paths)} images")
    return image_paths, labels

def create_data_transforms():
    """Create data transforms for training and validation"""
    
    train_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(p=0.5),
        transforms.RandomRotation(10),
        transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    return train_transform, val_transform

def train_model(model, train_loader, val_loader, num_epochs=50, learning_rate=0.001):
    """Train the model"""
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=20, gamma=0.1)
    
    train_losses = []
    val_losses = []
    val_accuracies = []
    
    for epoch in range(num_epochs):
        # Training
        model.train()
        train_loss = 0.0
        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
        
        # Validation
        model.eval()
        val_loss = 0.0
        correct = 0
        total = 0
        
        with torch.no_grad():
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                loss = criterion(outputs, labels)
                val_loss += loss.item()
                
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        train_loss /= len(train_loader)
        val_loss /= len(val_loader)
        accuracy = 100 * correct / total
        
        train_losses.append(train_loss)
        val_losses.append(val_loss)
        val_accuracies.append(accuracy)
        
        print(f'Epoch [{epoch+1}/{num_epochs}], Train Loss: {train_loss:.4f}, Val Loss: {val_loss:.4f}, Val Acc: {accuracy:.2f}%')
        
        scheduler.step()
    
    return train_losses, val_losses, val_accuracies

def save_model(model, save_path):
    """Save the trained model"""
    torch.save({
        'model_state_dict': model.state_dict(),
        'model_architecture': 'resnet18',
        'num_classes': 5,
        'class_names': ['lumpy_skin', 'fmd', 'mastitis', 'healthy', 'dermatitis']
    }, save_path)
    print(f"Model saved to {save_path}")

def validate_data(image_paths, labels):
    """Validate the loaded data"""
    print("Validating data...")
    
    # Check if we have images
    if len(image_paths) == 0:
        raise ValueError("No images found!")
    
    # Check if all images exist
    missing_images = []
    for path in image_paths[:10]:  # Check first 10 images
        if not os.path.exists(path):
            missing_images.append(path)
    
    if missing_images:
        print(f"Warning: {len(missing_images)} images not found")
    
    # Check label distribution
    from collections import Counter
    label_counts = Counter(labels)
    print("Label distribution:")
    for label, count in label_counts.items():
        print(f"  Class {label}: {count} images")
    
    # Check for class imbalance
    min_count = min(label_counts.values())
    max_count = max(label_counts.values())
    imbalance_ratio = max_count / min_count if min_count > 0 else float('inf')
    
    if imbalance_ratio > 10:
        print(f"Warning: Severe class imbalance detected (ratio: {imbalance_ratio:.1f})")
    
    return True

def main():
    """Main training function"""
    
    try:
        # Configuration
        data_dir = "assets/unlabeled_data"
        model_save_path = "assets/models/livestock_disease_model.pth"
        batch_size = 32
        num_epochs = 50
        
        # Create models directory
        os.makedirs("assets/models", exist_ok=True)
        
        print("Loading and processing data...")
        image_paths, labels = load_and_process_data(data_dir)
        
        if len(image_paths) == 0:
            print("No data found! Please check your data directory.")
            return
        
        print(f"Loaded {len(image_paths)} images")
        
        # Validate data
        validate_data(image_paths, labels)
        
        # Create transforms
        train_transform, val_transform = create_data_transforms()
        
        # Split data with stratification
        try:
            train_paths, val_paths, train_labels, val_labels = train_test_split(
                image_paths, labels, test_size=0.2, random_state=42, stratify=labels
            )
        except ValueError as e:
            print(f"Stratification failed: {e}")
            print("Using random split instead...")
            train_paths, val_paths, train_labels, val_labels = train_test_split(
                image_paths, labels, test_size=0.2, random_state=42
            )
        
        print(f"Training set: {len(train_paths)} images")
        print(f"Validation set: {len(val_paths)} images")
        
        # Create datasets
        train_dataset = LivestockDataset(train_paths, train_labels, train_transform)
        val_dataset = LivestockDataset(val_paths, val_labels, val_transform)
        
        # Create data loaders
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=2)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False, num_workers=2)
        
        # Create model
        model = DiseaseClassifier(num_classes=5)
        
        print("Starting training...")
        train_losses, val_losses, val_accuracies = train_model(
            model, train_loader, val_loader, num_epochs
        )
        
        # Save model
        save_model(model, model_save_path)
        
        # Plot training curves
        plt.figure(figsize=(12, 4))
        
        plt.subplot(1, 2, 1)
        plt.plot(train_losses, label='Train Loss')
        plt.plot(val_losses, label='Validation Loss')
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.legend()
        plt.title('Training and Validation Loss')
        
        plt.subplot(1, 2, 2)
        plt.plot(val_accuracies, label='Validation Accuracy')
        plt.xlabel('Epoch')
        plt.ylabel('Accuracy (%)')
        plt.legend()
        plt.title('Validation Accuracy')
        
        plt.tight_layout()
        plt.savefig('assets/models/training_curves.png')
        plt.show()
        
        print("Training completed successfully!")
        
    except Exception as e:
        print(f"Error during training: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

if __name__ == "__main__":
    main()
