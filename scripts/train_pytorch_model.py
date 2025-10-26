#!/usr/bin/env python3
"""
Train 90%+ Accuracy Livestock Disease Detection Model
Advanced ensemble approach with state-of-the-art techniques
"""

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, WeightedRandomSampler
import torchvision.transforms as transforms
from torchvision.models import efficientnet_b4, resnet50, vit_b_16, densenet201
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.utils.class_weight import compute_class_weight
import matplotlib.pyplot as plt
import seaborn as sns
from PIL import Image
import os
import json
from pathlib import Path
import albumentations as A
from albumentations.pytorch import ToTensorV2
import warnings
from collections import Counter
import cv2
warnings.filterwarnings('ignore')

class AdvancedEnsembleModel(nn.Module):
    """Advanced ensemble model for 90%+ accuracy"""
    
    def __init__(self, num_classes=5, dropout_rate=0.4):
        super(AdvancedEnsembleModel, self).__init__()
        
        # EfficientNet-B4 (best for medical images)
        self.efficientnet = efficientnet_b4(pretrained=True)
        self.efficientnet.classifier = nn.Sequential(
            nn.Dropout(dropout_rate),
            nn.Linear(self.efficientnet.classifier[1].in_features, 1024),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(1024, 512),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(512, num_classes)
        )
        
        # ResNet50 (robust baseline)
        self.resnet = resnet50(pretrained=True)
        self.resnet.fc = nn.Sequential(
            nn.Dropout(dropout_rate),
            nn.Linear(self.resnet.fc.in_features, 1024),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(1024, 512),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(512, num_classes)
        )
        
        # Vision Transformer (state-of-the-art)
        self.vit = vit_b_16(pretrained=True)
        self.vit.heads = nn.Sequential(
            nn.Dropout(dropout_rate),
            nn.Linear(self.vit.heads[0].in_features, 1024),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(1024, 512),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(512, num_classes)
        )
        
        # DenseNet201 (dense connections)
        self.densenet = densenet201(pretrained=True)
        self.densenet.classifier = nn.Sequential(
            nn.Dropout(dropout_rate),
            nn.Linear(self.densenet.classifier.in_features, 1024),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(1024, 512),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(512, num_classes)
        )
        
        # Advanced ensemble fusion with attention
        self.attention = nn.MultiheadAttention(embed_dim=num_classes, num_heads=1)
        self.fusion = nn.Sequential(
            nn.Linear(num_classes * 4, 1024),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(1024, 512),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Dropout(dropout_rate),
            nn.Linear(256, num_classes)
        )
        
    def forward(self, x):
        # Get predictions from all models
        eff_out = self.efficientnet(x)
        res_out = self.resnet(x)
        vit_out = self.vit(x)
        dense_out = self.densenet(x)
        
        # Stack outputs for attention mechanism
        stacked_outputs = torch.stack([eff_out, res_out, vit_out, dense_out], dim=1)
        
        # Apply attention mechanism
        attended_outputs, _ = self.attention(
            stacked_outputs, stacked_outputs, stacked_outputs
        )
        
        # Flatten and fuse
        combined = attended_outputs.view(attended_outputs.size(0), -1)
        final_out = self.fusion(combined)
        
        return final_out

class AdvancedDataset:
    """Advanced dataset with comprehensive augmentation and balancing"""
    
    def __init__(self, data_dir, transform=None, is_training=True):
        self.data_dir = Path(data_dir)
        self.transform = transform
        self.is_training = is_training
        self.images = []
        self.labels = []
        self.class_names = ['lumpy_skin', 'fmd', 'mastitis', 'healthy', 'dermatitis']
        self.class_to_idx = {name: idx for idx, name in enumerate(self.class_names)}
        
        # Load all data sources
        self._load_all_data()
        
        print(f"Total samples: {len(self.images)}")
        print(f"Class distribution: {Counter(self.labels)}")
        
    def _load_all_data(self):
        """Load data from all available sources"""
        
        # Load multiclass data
        self._load_multiclass_data()
        
        # Load YOLO data
        self._load_yolo_data()
        
        # Load augmented data
        self._load_augmented_data()
        
        # Balance dataset
        self._balance_dataset()
    
    def _load_multiclass_data(self):
        """Load multiclass dataset"""
        multiclass_dir = self.data_dir / "cattle diseases.v2i.multiclass"
        if multiclass_dir.exists():
            classes_file = multiclass_dir / "train" / "_classes.csv"
            if classes_file.exists():
                classes_df = pd.read_csv(classes_file)
                class_mapping = {row['class']: idx for idx, row in classes_df.iterrows()}
                
                for split in ['train', 'valid', 'test']:
                    split_dir = multiclass_dir / split
                    if split_dir.exists():
                        for class_name in class_mapping.keys():
                            class_dir = split_dir / class_name
                            if class_dir.exists():
                                for img_file in class_dir.glob('*.jpg'):
                                    self.images.append(str(img_file))
                                    self.labels.append(class_mapping[class_name])
    
    def _load_yolo_data(self):
        """Load YOLO dataset"""
        yolo_dir = self.data_dir / "cattle diseases.v2i.yolov11"
        if yolo_dir.exists():
            # YOLO class mapping to our classes
            yolo_mapping = {
                0: 0,  # lumpy_skin
                1: 1,  # fmd
                2: 2,  # mastitis
                3: 3,  # healthy
                4: 4   # dermatitis
            }
            
            for split in ['train', 'test']:
                split_dir = yolo_dir / split
                if split_dir.exists():
                    for img_file in split_dir.glob('*.jpg'):
                        label_file = split_dir / f"{img_file.stem}.txt"
                        if label_file.exists():
                            with open(label_file, 'r') as f:
                                lines = f.readlines()
                                if lines:
                                    class_id = int(lines[0].split()[0])
                                    if class_id in yolo_mapping:
                                        self.images.append(str(img_file))
                                        self.labels.append(yolo_mapping[class_id])
    
    def _load_augmented_data(self):
        """Load augmented datasets"""
        # High contrast augmented (healthy)
        hc_dir = self.data_dir / "hcaugmented"
        if hc_dir.exists():
            for img_file in hc_dir.glob('*.jpg'):
                self.images.append(str(img_file))
                self.labels.append(3)  # healthy
        
        # Low contrast augmented (lumpy skin)
        lc_dir = self.data_dir / "lcaugmented"
        if lc_dir.exists():
            for img_file in lc_dir.glob('*.jpg'):
                self.images.append(str(img_file))
                self.labels.append(0)  # lumpy_skin
    
    def _balance_dataset(self):
        """Balance dataset using oversampling"""
        from collections import Counter
        
        # Count samples per class
        class_counts = Counter(self.labels)
        max_count = max(class_counts.values())
        
        # Oversample minority classes
        balanced_images = []
        balanced_labels = []
        
        for class_id in range(len(self.class_names)):
            class_indices = [i for i, label in enumerate(self.labels) if label == class_id]
            current_count = len(class_indices)
            
            if current_count < max_count:
                # Oversample
                oversample_factor = max_count // current_count
                remainder = max_count % current_count
                
                for _ in range(oversample_factor):
                    balanced_images.extend([self.images[i] for i in class_indices])
                    balanced_labels.extend([self.labels[i] for i in class_indices])
                
                # Add remainder
                for i in range(remainder):
                    balanced_images.append(self.images[class_indices[i]])
                    balanced_labels.append(self.labels[class_indices[i]])
            else:
                # Use all samples
                balanced_images.extend([self.images[i] for i in class_indices])
                balanced_labels.extend([self.labels[i] for i in class_indices])
        
        self.images = balanced_images
        self.labels = balanced_labels
        
        print(f"Balanced dataset size: {len(self.images)}")
        print(f"Balanced class distribution: {Counter(self.labels)}")
    
    def __len__(self):
        return len(self.images)
    
    def __getitem__(self, idx):
        img_path = self.images[idx]
        label = self.labels[idx]
        
        try:
            image = Image.open(img_path).convert('RGB')
            
            if self.transform:
                if isinstance(self.transform, A.Compose):
                    image = np.array(image)
                    transformed = self.transform(image=image)
                    image = transformed['image']
                else:
                    image = self.transform(image)
            
            return image, label
        except Exception as e:
            print(f"Error loading {img_path}: {e}")
            # Return a dummy image
            dummy_img = Image.new('RGB', (224, 224), (0, 0, 0))
            if self.transform:
                dummy_img = self.transform(dummy_img)
            return dummy_img, 0

class AdvancedTrainer:
    """Advanced trainer with state-of-the-art techniques"""
    
    def __init__(self, model, device, num_classes=5):
        self.model = model.to(device)
        self.device = device
        self.num_classes = num_classes
        
        # Advanced optimizer with different learning rates
        self.optimizer = optim.AdamW([
            {'params': [p for n, p in model.named_parameters() if 'fusion' not in n], 'lr': 1e-5},
            {'params': [p for n, p in model.named_parameters() if 'fusion' in n], 'lr': 1e-4}
        ], weight_decay=0.01)
        
        # Advanced scheduler
        self.scheduler = optim.lr_scheduler.CosineAnnealingWarmRestarts(
            self.optimizer, T_0=15, T_mult=2, eta_min=1e-7
        )
        
        # Focal loss for handling class imbalance
        self.criterion = self._focal_loss
        
        # Early stopping
        self.best_acc = 0
        self.patience = 20
        self.patience_counter = 0
        
    def _focal_loss(self, inputs, targets, alpha=0.25, gamma=2.0):
        """Focal loss for handling class imbalance"""
        ce_loss = nn.CrossEntropyLoss()(inputs, targets)
        pt = torch.exp(-ce_loss)
        focal_loss = alpha * (1 - pt) ** gamma * ce_loss
        return focal_loss
    
    def train_epoch(self, train_loader):
        """Train one epoch with advanced techniques"""
        self.model.train()
        total_loss = 0
        correct = 0
        total = 0
        
        for batch_idx, (data, target) in enumerate(train_loader):
            data, target = data.to(self.device), target.to(self.device)
            
            self.optimizer.zero_grad()
            output = self.model(data)
            loss = self.criterion(output, target)
            loss.backward()
            
            # Gradient clipping
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
            
            self.optimizer.step()
            
            total_loss += loss.item()
            pred = output.argmax(dim=1, keepdim=True)
            correct += pred.eq(target.view_as(pred)).sum().item()
            total += target.size(0)
            
            if batch_idx % 50 == 0:
                print(f'Batch {batch_idx}, Loss: {loss.item():.4f}, Acc: {100.*correct/total:.2f}%')
        
        return total_loss / len(train_loader), 100. * correct / total
    
    def validate(self, val_loader):
        """Validate with detailed metrics"""
        self.model.eval()
        val_loss = 0
        correct = 0
        total = 0
        all_preds = []
        all_targets = []
        
        with torch.no_grad():
            for data, target in val_loader:
                data, target = data.to(self.device), target.to(self.device)
                output = self.model(data)
                val_loss += self.criterion(output, target).item()
                
                pred = output.argmax(dim=1, keepdim=True)
                correct += pred.eq(target.view_as(pred)).sum().item()
                total += target.size(0)
                
                all_preds.extend(pred.cpu().numpy())
                all_targets.extend(target.cpu().numpy())
        
        accuracy = 100. * correct / total
        avg_loss = val_loss / len(val_loader)
        
        return avg_loss, accuracy, all_preds, all_targets
    
    def train(self, train_loader, val_loader, epochs=150):
        """Main training loop with advanced techniques"""
        train_losses = []
        val_losses = []
        train_accs = []
        val_accs = []
        
        for epoch in range(epochs):
            print(f'\nEpoch {epoch+1}/{epochs}')
            print('-' * 50)
            
            # Train
            train_loss, train_acc = self.train_epoch(train_loader)
            
            # Validate
            val_loss, val_acc, val_preds, val_targets = self.validate(val_loader)
            
            # Update scheduler
            self.scheduler.step()
            
            # Store metrics
            train_losses.append(train_loss)
            val_losses.append(val_loss)
            train_accs.append(train_acc)
            val_accs.append(val_acc)
            
            print(f'Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.2f}%')
            print(f'Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.2f}%')
            print(f'Learning Rate: {self.optimizer.param_groups[0]["lr"]:.6f}')
            
            # Early stopping
            if val_acc > self.best_acc:
                self.best_acc = val_acc
                self.patience_counter = 0
                # Save best model
                torch.save(self.model.state_dict(), 'best_90_percent_model.pth')
                print(f'New best model saved! Accuracy: {val_acc:.2f}%')
            else:
                self.patience_counter += 1
                if self.patience_counter >= self.patience:
                    print(f'Early stopping at epoch {epoch+1}')
                    break
        
        # Load best model
        self.model.load_state_dict(torch.load('best_90_percent_model.pth'))
        
        return train_losses, val_losses, train_accs, val_accs

def create_advanced_transforms():
    """Create advanced data augmentation transforms"""
    
    # Training transforms with heavy augmentation
    train_transform = A.Compose([
        A.Resize(256, 256),
        A.RandomCrop(224, 224),
        A.HorizontalFlip(p=0.5),
        A.VerticalFlip(p=0.3),
        A.RandomRotate90(p=0.5),
        A.Rotate(limit=45, p=0.5),
        A.RandomBrightnessContrast(brightness_limit=0.4, contrast_limit=0.4, p=0.6),
        A.HueSaturationValue(hue_shift_limit=30, sat_shift_limit=40, val_shift_limit=30, p=0.6),
        A.GaussNoise(var_limit=(10.0, 80.0), p=0.4),
        A.GaussianBlur(blur_limit=5, p=0.4),
        A.ElasticTransform(alpha=1, sigma=50, alpha_affine=50, p=0.4),
        A.GridDistortion(num_steps=5, distort_limit=0.4, p=0.4),
        A.OpticalDistortion(distort_limit=0.4, shift_limit=0.1, p=0.4),
        A.CoarseDropout(max_holes=12, max_height=32, max_width=32, p=0.4),
        A.Cutout(num_holes=8, max_h_size=32, max_w_size=32, p=0.3),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2()
    ])
    
    # Validation transforms (minimal augmentation)
    val_transform = A.Compose([
        A.Resize(224, 224),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2()
    ])
    
    return train_transform, val_transform

def main():
    """Main training function for 90%+ accuracy"""
    print("🚀 Training 90%+ Accuracy Livestock Disease Detection Model")
    print("Advanced ensemble approach with state-of-the-art techniques")
    print("=" * 70)
    
    # Setup
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")
    
    # Data directory
    data_dir = Path("assets/unlabeled_data")
    if not data_dir.exists():
        print(f"Data directory not found: {data_dir}")
        return
    
    # Create transforms
    train_transform, val_transform = create_advanced_transforms()
    
    # Create datasets
    print("\n📁 Loading and balancing datasets...")
    train_dataset = AdvancedDataset(data_dir, transform=train_transform, is_training=True)
    
    # Split data
    train_size = int(0.8 * len(train_dataset))
    val_size = len(train_dataset) - train_size
    train_dataset, val_dataset = torch.utils.data.random_split(
        train_dataset, [train_size, val_size]
    )
    
    # Update validation dataset transform
    val_dataset.dataset.transform = val_transform
    
    # Create data loaders
    train_loader = DataLoader(
        train_dataset, batch_size=12, shuffle=True, num_workers=4, pin_memory=True
    )
    val_loader = DataLoader(
        val_dataset, batch_size=24, shuffle=False, num_workers=4, pin_memory=True
    )
    
    print(f"Train samples: {len(train_dataset)}")
    print(f"Validation samples: {len(val_dataset)}")
    
    # Create advanced ensemble model
    print("\n🧠 Creating advanced ensemble model...")
    model = AdvancedEnsembleModel(num_classes=5)
    print(f"Model parameters: {sum(p.numel() for p in model.parameters()):,}")
    
    # Create trainer
    trainer = AdvancedTrainer(model, device)
    
    # Train model
    print("\n🎯 Starting training for 90%+ accuracy...")
    train_losses, val_losses, train_accs, val_accs = trainer.train(
        train_loader, val_loader, epochs=150
    )
    
    # Plot training curves
    plt.figure(figsize=(15, 5))
    
    plt.subplot(1, 2, 1)
    plt.plot(train_losses, label='Train Loss')
    plt.plot(val_losses, label='Val Loss')
    plt.title('Training and Validation Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()
    plt.grid(True)
    
    plt.subplot(1, 2, 2)
    plt.plot(train_accs, label='Train Accuracy')
    plt.plot(val_accs, label='Val Accuracy')
    plt.title('Training and Validation Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy (%)')
    plt.legend()
    plt.grid(True)
    
    plt.tight_layout()
    plt.savefig('training_curves_90_percent.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # Final evaluation
    print("\n📊 Final evaluation...")
    val_loss, val_acc, val_preds, val_targets = trainer.validate(val_loader)
    
    print(f"Final Validation Accuracy: {val_acc:.2f}%")
    
    # Classification report
    class_names = ['lumpy_skin', 'fmd', 'mastitis', 'healthy', 'dermatitis']
    print("\nClassification Report:")
    print(classification_report(val_targets, val_preds, target_names=class_names))
    
    # Confusion matrix
    cm = confusion_matrix(val_targets, val_preds)
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                xticklabels=class_names, yticklabels=class_names)
    plt.title('Confusion Matrix - 90%+ Accuracy Model')
    plt.xlabel('Predicted')
    plt.ylabel('Actual')
    plt.tight_layout()
    plt.savefig('confusion_matrix_90_percent.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # Save model info
    model_info = {
        'accuracy': float(val_acc),
        'classes': class_names,
        'model_type': 'advanced_ensemble_efficientnet_resnet_vit_densenet',
        'training_samples': len(train_dataset),
        'validation_samples': len(val_dataset),
        'target_accuracy': 90.0,
        'achieved': val_acc >= 90.0
    }
    
    with open('model_info_90_percent.json', 'w') as f:
        json.dump(model_info, f, indent=2)
    
    print(f"\n🎉 Training complete!")
    print(f"Best accuracy: {trainer.best_acc:.2f}%")
    print(f"Model saved as: best_90_percent_model.pth")
    print(f"Model info saved as: model_info_90_percent.json")
    
    if trainer.best_acc >= 90:
        print("🎯 TARGET ACHIEVED: 90%+ accuracy!")
        print("✅ Model ready for TensorFlow Lite conversion")
    else:
        print(f"⚠️  Target not reached. Current: {trainer.best_acc:.2f}%")
        print("💡 Consider more training data or longer training")

if __name__ == "__main__":
    main()
