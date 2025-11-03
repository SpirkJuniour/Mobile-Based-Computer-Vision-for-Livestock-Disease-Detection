#!/usr/bin/env python3
"""
Livestock Disease Detection Model Training
Optimized for RTX 3050 GPU - Target: >95% Accuracy
Uses all 4 datasets: lcaugmented, hcaugmented, yolov11, multiclass
"""

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
import torchvision.transforms as transforms
from torchvision.models import resnet50, ResNet50_Weights
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import seaborn as sns
from PIL import Image
import os
import json
from pathlib import Path
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, precision_recall_fscore_support
from tqdm import tqdm
import warnings
import csv
from datetime import datetime
warnings.filterwarnings('ignore')

# Set style for beautiful plots
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")

class ComprehensiveLivestockDataset(Dataset):
    """
    Dataset loader that combines all 4 datasets:
    1. lcaugmented - Lumpy skin augmented images
    2. hcaugmented - Healthy cattle augmented images  
    3. cattle diseases.v2i.yolov11 - YOLO format dataset
    4. cattle diseases.v2i.multiclass - Multiclass dataset
    """
    
    def __init__(self, root_dir, transform=None, split='train', test_split_ratio=0.2):
        self.root_dir = Path(root_dir)
        self.transform = transform
        self.split = split
        self.test_split_ratio = test_split_ratio
        
        # Define disease classes
        self.class_to_idx = {
            'healthy': 0,
            'lumpy_skin': 1,
            'fmd': 2,
            'mastitis': 3,
            'dermatitis': 4
        }
        self.idx_to_class = {v: k for k, v in self.class_to_idx.items()}
        
        self.images = []
        self.labels = []
        
        print(f"\n{'='*70}")
        print(f"Loading {split.upper()} Dataset from 4 Sources")
        print(f"{'='*70}")
        
        self._load_all_datasets()
        self._split_dataset()
        
        print(f"\n{'='*70}")
        print(f"[OK] Loaded {len(self.images)} {split} images")
        print(f"{'='*70}\n")
    
    def _load_all_datasets(self):
        """Load images from all 4 datasets"""
        all_images = []
        all_labels = []
        
        # 1. Load lcaugmented - All images are lumpy_skin disease
        print("\n[1/4] Loading lcaugmented dataset...")
        lcaug_dir = self.root_dir / "lcaugmented"
        if lcaug_dir.exists():
            lc_images = list(lcaug_dir.glob('*.jpg'))
            all_images.extend([str(img) for img in lc_images])
            all_labels.extend([self.class_to_idx['lumpy_skin']] * len(lc_images))
            print(f"  [OK] Found {len(lc_images)} lumpy_skin images")
        
        # 2. Load hcaugmented - All images are healthy cattle
        print("[2/4] Loading hcaugmented dataset...")
        hcaug_dir = self.root_dir / "hcaugmented"
        if hcaug_dir.exists():
            hc_images = list(hcaug_dir.glob('*.jpg'))
            all_images.extend([str(img) for img in hc_images])
            all_labels.extend([self.class_to_idx['healthy']] * len(hc_images))
            print(f"  [OK] Found {len(hc_images)} healthy images")
        
        # 3. Load YOLO dataset
        print("[3/4] Loading cattle diseases.v2i.yolov11 dataset...")
        yolo_dir = self.root_dir / "cattle diseases.v2i.yolov11"
        if yolo_dir.exists():
            yolo_count = 0
            for split_name in ['train', 'valid', 'test']:
                split_dir = yolo_dir / split_name
                if split_dir.exists():
                    for img_path in split_dir.glob('*.jpg'):
                        label = self._infer_label_from_filename(img_path.name)
                        if label is not None:
                            all_images.append(str(img_path))
                            all_labels.append(self.class_to_idx[label])
                            yolo_count += 1
            print(f"  [OK] Found {yolo_count} images")
        
        # 4. Load multiclass dataset
        print("[4/4] Loading cattle diseases.v2i.multiclass dataset...")
        multi_dir = self.root_dir / "cattle diseases.v2i.multiclass"
        if multi_dir.exists():
            multi_count = 0
            for split_name in ['train', 'valid', 'test']:
                split_dir = multi_dir / split_name
                if split_dir.exists():
                    for img_path in split_dir.glob('*.jpg'):
                        label = self._infer_label_from_filename(img_path.name)
                        if label is not None:
                            all_images.append(str(img_path))
                            all_labels.append(self.class_to_idx[label])
                            multi_count += 1
            print(f"  [OK] Found {multi_count} images")
        
        self.all_images = all_images
        self.all_labels = all_labels
        
        print(f"\nTotal images loaded: {len(all_images)}")
        self._print_class_distribution(all_labels, "Combined Dataset")
    
    def _infer_label_from_filename(self, filename):
        """Infer disease label from filename"""
        filename_lower = filename.lower()
        
        # Check for lumpy skin disease
        if any(kw in filename_lower for kw in ['lumpy', 'lsd', 'lump']):
            return 'lumpy_skin'
        
        # Check for FMD (Foot and Mouth Disease)
        elif any(kw in filename_lower for kw in ['fmd', 'foot-and-mouth', 'foot_mouth']):
            return 'fmd'
        
        # Check for mastitis
        elif 'mastitis' in filename_lower:
            return 'mastitis'
        
        # Check for dermatitis
        elif any(kw in filename_lower for kw in ['dermatitis', 'dermatosis', 'fungal', 'skin']):
            # Make sure it's not lumpy_skin
            if 'lumpy' not in filename_lower:
                return 'dermatitis'
        
        # Check for healthy cattle
        elif any(kw in filename_lower for kw in ['healthy', 'sehat', 'normal', 'ayrshire', 'jersey', 'holstein']):
            return 'healthy'
        
        # Default to healthy for cattle breed names
        elif any(kw in filename_lower for kw in ['cattle', 'cow', 'bull']):
            if not any(disease in filename_lower for disease in ['lumpy', 'fmd', 'mastitis', 'dermatitis']):
                return 'healthy'
        
        return None
    
    def _split_dataset(self):
        """Split dataset into train/test based on split parameter"""
        # Shuffle with fixed seed for reproducibility
        indices = list(range(len(self.all_images)))
        np.random.seed(42)
        np.random.shuffle(indices)
        
        # Split by class to maintain class balance
        train_indices = []
        test_indices = []
        
        for class_idx in range(len(self.class_to_idx)):
            class_indices = [i for i in indices if self.all_labels[i] == class_idx]
            split_point = int(len(class_indices) * (1 - self.test_split_ratio))
            train_indices.extend(class_indices[:split_point])
            test_indices.extend(class_indices[split_point:])
        
        if self.split == 'train':
            selected_indices = train_indices
        else:
            selected_indices = test_indices
        
        self.images = [self.all_images[i] for i in selected_indices]
        self.labels = [self.all_labels[i] for i in selected_indices]
        
        self._print_class_distribution(self.labels, f"{self.split.upper()} Split")
    
    def _print_class_distribution(self, labels, title):
        """Print class distribution"""
        print(f"\n{title} - Class Distribution:")
        print("-" * 50)
        for class_name, class_idx in self.class_to_idx.items():
            count = labels.count(class_idx)
            percentage = (count / len(labels) * 100) if len(labels) > 0 else 0
            print(f"  {class_name:15s}: {count:5d} images ({percentage:5.2f}%)")
    
    def get_class_weights(self):
        """Calculate class weights for balanced training"""
        class_counts = [self.labels.count(i) for i in range(len(self.class_to_idx))]
        total = sum(class_counts)
        weights = [total / (len(self.class_to_idx) * count) if count > 0 else 0 
                  for count in class_counts]
        return torch.FloatTensor(weights)
    
    def get_sample_weights(self):
        """Get sample weights for weighted random sampling"""
        class_weights = self.get_class_weights()
        sample_weights = [class_weights[label] for label in self.labels]
        return sample_weights
    
    def __len__(self):
        return len(self.images)
    
    def __getitem__(self, idx):
        img_path = self.images[idx]
        label = self.labels[idx]
        
        try:
            image = Image.open(img_path).convert('RGB')
            if self.transform:
                image = self.transform(image)
            return image, label
        except Exception as e:
            print(f"Warning: Error loading {img_path}: {e}")
            # Return next valid image
            return self.__getitem__((idx + 1) % len(self))


def create_advanced_model(num_classes=5, pretrained=True):
    """Create ResNet50 model (faster and fits in GPU)"""
    print("\n" + "="*70)
    print("Creating Model - ResNet50 (GPU-optimized)")
    print("="*70)
    
    if pretrained:
        model = resnet50(weights=ResNet50_Weights.DEFAULT)
        print("[OK] Loaded pretrained ImageNet weights")
    else:
        model = resnet50(weights=None)
    
    # Modify final layer for our classes
    in_features = model.fc.in_features
    model.fc = nn.Sequential(
        nn.Dropout(p=0.3),
        nn.Linear(in_features, 512),
        nn.ReLU(),
        nn.Dropout(p=0.2),
        nn.Linear(512, num_classes)
    )
    
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    
    print(f"[OK] Total parameters: {total_params:,}")
    print(f"[OK] Trainable parameters: {trainable_params:,}")
    print("="*70 + "\n")
    
    return model


def train_one_epoch(model, dataloader, criterion, optimizer, device, epoch):
    """Train for one epoch with progress tracking"""
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    pbar = tqdm(dataloader, desc=f'Epoch {epoch} - Training', 
                bar_format='{l_bar}{bar:30}{r_bar}{bar:-10b}')
    
    for images, labels in pbar:
        images, labels = images.to(device), labels.to(device)
        
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        
        # Gradient clipping to prevent exploding gradients
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        
        optimizer.step()
        
        running_loss += loss.item()
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
        
        # Update progress bar
        current_acc = 100 * correct / total
        pbar.set_postfix({
            'loss': f'{loss.item():.4f}',
            'acc': f'{current_acc:.2f}%'
        })
    
    epoch_loss = running_loss / len(dataloader)
    epoch_acc = 100 * correct / total
    
    return epoch_loss, epoch_acc


def evaluate(model, dataloader, criterion, device, phase='Validation'):
    """Evaluate model with detailed metrics"""
    model.eval()
    running_loss = 0.0
    all_preds = []
    all_labels = []
    all_probs = []
    
    with torch.no_grad():
        pbar = tqdm(dataloader, desc=f'{phase}', 
                   bar_format='{l_bar}{bar:30}{r_bar}{bar:-10b}')
        
        for images, labels in pbar:
            images, labels = images.to(device), labels.to(device)
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            running_loss += loss.item()
            
            # Get probabilities and predictions
            probs = torch.softmax(outputs, dim=1)
            _, predicted = torch.max(outputs.data, 1)
            
            all_preds.extend(predicted.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            all_probs.extend(probs.cpu().numpy())
    
    epoch_loss = running_loss / len(dataloader)
    epoch_acc = accuracy_score(all_labels, all_preds) * 100
    
    return epoch_loss, epoch_acc, all_preds, all_labels, all_probs


def plot_training_history(train_losses, train_accs, val_losses, val_accs, save_dir):
    """Create comprehensive training history visualization"""
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))
    
    epochs = range(1, len(train_losses) + 1)
    
    # Loss plot
    ax = axes[0]
    ax.plot(epochs, train_losses, 'b-o', label='Training', linewidth=2.5, markersize=8)
    ax.plot(epochs, val_losses, 'r-s', label='Validation', linewidth=2.5, markersize=8)
    ax.set_title('Training and Validation Loss', fontsize=16, fontweight='bold', pad=15)
    ax.set_xlabel('Epoch', fontsize=13, fontweight='bold')
    ax.set_ylabel('Loss', fontsize=13, fontweight='bold')
    ax.legend(fontsize=12, frameon=True, shadow=True)
    ax.grid(True, alpha=0.3, linestyle='--')
    
    # Accuracy plot
    ax = axes[1]
    ax.plot(epochs, train_accs, 'b-o', label='Training', linewidth=2.5, markersize=8)
    ax.plot(epochs, val_accs, 'r-s', label='Validation', linewidth=2.5, markersize=8)
    ax.set_title('Training and Validation Accuracy', fontsize=16, fontweight='bold', pad=15)
    ax.set_xlabel('Epoch', fontsize=13, fontweight='bold')
    ax.set_ylabel('Accuracy (%)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=12, frameon=True, shadow=True)
    ax.grid(True, alpha=0.3, linestyle='--')
    ax.axhline(y=95, color='g', linestyle='--', linewidth=2, label='Target: >95%', alpha=0.7)
    
    plt.tight_layout()
    save_path = save_dir / 'training_history.png'
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[OK] Training history saved: {save_path}")


def plot_confusion_matrix(y_true, y_pred, class_names, save_dir, phase='Validation'):
    """Create detailed confusion matrix"""
    cm = confusion_matrix(y_true, y_pred)
    
    # Calculate percentages
    cm_percent = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis] * 100
    
    fig, ax = plt.subplots(figsize=(12, 10))
    
    # Create annotations with both count and percentage
    annotations = np.empty_like(cm, dtype=object)
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            annotations[i, j] = f'{cm[i, j]}\n({cm_percent[i, j]:.1f}%)'
    
    sns.heatmap(cm, annot=annotations, fmt='', cmap='Blues', 
                xticklabels=class_names, yticklabels=class_names,
                cbar_kws={'label': 'Number of Predictions'},
                linewidths=1, linecolor='gray', ax=ax)
    
    ax.set_title(f'{phase} Confusion Matrix', fontsize=18, fontweight='bold', pad=20)
    ax.set_ylabel('True Label', fontsize=14, fontweight='bold')
    ax.set_xlabel('Predicted Label', fontsize=14, fontweight='bold')
    plt.xticks(rotation=45, ha='right', fontsize=11)
    plt.yticks(rotation=0, fontsize=11)
    
    plt.tight_layout()
    save_path = save_dir / f'confusion_matrix_{phase.lower()}.png'
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[OK] Confusion matrix saved: {save_path}")


def plot_per_class_metrics(report_dict, class_names, save_dir):
    """Visualize per-class performance metrics"""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    # Extract metrics
    metrics = ['precision', 'recall', 'f1-score']
    colors = ['#3498db', '#2ecc71', '#f39c12']
    
    # Plot 1: Per-class metrics comparison
    ax = axes[0, 0]
    x = np.arange(len(class_names))
    width = 0.25
    
    for i, metric in enumerate(metrics):
        values = [report_dict[cls][metric] * 100 for cls in class_names]
        ax.bar(x + i*width, values, width, label=metric.capitalize(), 
               color=colors[i], alpha=0.8, edgecolor='black', linewidth=1.5)
    
    ax.set_ylabel('Score (%)', fontsize=12, fontweight='bold')
    ax.set_title('Per-Class Metrics Comparison', fontsize=14, fontweight='bold')
    ax.set_xticks(x + width)
    ax.set_xticklabels(class_names, rotation=45, ha='right')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    ax.set_ylim([0, 105])
    
    # Plot 2: F1-Score ranking
    ax = axes[0, 1]
    f1_scores = [report_dict[cls]['f1-score'] * 100 for cls in class_names]
    sorted_data = sorted(zip(class_names, f1_scores), key=lambda x: x[1], reverse=True)
    sorted_classes, sorted_f1 = zip(*sorted_data)
    
    bars = ax.barh(sorted_classes, sorted_f1, color='skyblue', alpha=0.8, 
                   edgecolor='black', linewidth=1.5)
    ax.set_xlabel('F1-Score (%)', fontsize=12, fontweight='bold')
    ax.set_title('F1-Score Ranking', fontsize=14, fontweight='bold')
    ax.grid(axis='x', alpha=0.3)
    ax.set_xlim([0, 105])
    
    # Add value labels
    for i, bar in enumerate(bars):
        width = bar.get_width()
        ax.text(width + 1, bar.get_y() + bar.get_height()/2., 
                f'{width:.2f}%', ha='left', va='center', fontweight='bold')
    
    # Plot 3: Overall metrics
    ax = axes[1, 0]
    overall_metrics = ['Accuracy', 'Macro Precision', 'Macro Recall', 'Macro F1']
    overall_values = [
        report_dict['accuracy'] * 100,
        report_dict['macro avg']['precision'] * 100,
        report_dict['macro avg']['recall'] * 100,
        report_dict['macro avg']['f1-score'] * 100
    ]
    colors_overall = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    
    bars = ax.bar(overall_metrics, overall_values, color=colors_overall, 
                  alpha=0.8, edgecolor='black', linewidth=1.5)
    ax.set_ylabel('Score (%)', fontsize=12, fontweight='bold')
    ax.set_title('Overall Performance Metrics', fontsize=14, fontweight='bold')
    ax.grid(axis='y', alpha=0.3)
    ax.set_ylim([0, 105])
    plt.setp(ax.xaxis.get_majorticklabels(), rotation=15, ha='right')
    
    # Add value labels and target line
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f}%', ha='center', va='bottom', fontweight='bold')
    ax.axhline(y=95, color='green', linestyle='--', linewidth=2, alpha=0.7)
    ax.text(0.5, 95.5, 'Target: 95%', fontsize=10, color='green', fontweight='bold')
    
    # Plot 4: Support (number of samples per class)
    ax = axes[1, 1]
    support = [report_dict[cls]['support'] for cls in class_names]
    colors_pie = plt.cm.Set3(np.linspace(0, 1, len(class_names)))
    wedges, texts, autotexts = ax.pie(support, labels=class_names, autopct='%1.1f%%',
                                        colors=colors_pie, startangle=90,
                                        textprops={'fontsize': 10, 'weight': 'bold'})
    ax.set_title('Test Set Class Distribution', fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    save_path = save_dir / 'per_class_metrics.png'
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"[OK] Per-class metrics saved: {save_path}")


def save_training_log(history, save_dir):
    """Save training history to CSV"""
    csv_path = save_dir / 'training_log.csv'
    
    with open(csv_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Epoch', 'Train_Loss', 'Train_Acc', 'Val_Loss', 'Val_Acc'])
        
        for i in range(len(history['train_loss'])):
            writer.writerow([
                i + 1,
                f"{history['train_loss'][i]:.6f}",
                f"{history['train_acc'][i]:.4f}",
                f"{history['val_loss'][i]:.6f}",
                f"{history['val_acc'][i]:.4f}"
            ])
    
    print(f"[OK] Training log saved: {csv_path}")


def main():
    """Main training function"""
    print("\n" + "="*70)
    print("  LIVESTOCK DISEASE DETECTION - ADVANCED TRAINING")
    print("  Target: >95% Accuracy | GPU: RTX 3050")
    print("="*70 + "\n")
    
    # Configuration
    DATA_DIR = Path("assets/unlabeled_data")
    OUTPUT_DIR = Path("training_results")
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    # Hyperparameters optimized for RTX 3050 with ResNet50
    BATCH_SIZE = 32  # Good for GPU
    NUM_EPOCHS = 30  # Fewer epochs, faster completion
    INITIAL_LR = 0.001
    NUM_CLASSES = 5
    IMG_SIZE = 224  # Standard size, less memory
    
    # Device setup - Use GPU with smaller model
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Device: {device}")
    if torch.cuda.is_available():
        print(f"GPU: {torch.cuda.get_device_name(0)}")
        print("Using ResNet50 - fits in GPU memory")
    print()
    
    # Advanced data transforms with heavy augmentation for better generalization
    train_transform = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.RandomHorizontalFlip(p=0.5),
        transforms.RandomVerticalFlip(p=0.2),
        transforms.RandomRotation(20),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.1),
        transforms.RandomAffine(degrees=0, translate=(0.1, 0.1), scale=(0.9, 1.1)),
        transforms.RandomPerspective(distortion_scale=0.2, p=0.3),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        transforms.RandomErasing(p=0.2)
    ])
    
    test_transform = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    # Load datasets
    print("Loading Training Dataset...")
    train_dataset = ComprehensiveLivestockDataset(
        DATA_DIR, 
        transform=train_transform, 
        split='train',
        test_split_ratio=0.2
    )
    
    print("\nLoading Test Dataset...")
    test_dataset = ComprehensiveLivestockDataset(
        DATA_DIR, 
        transform=test_transform, 
        split='test',
        test_split_ratio=0.2
    )
    
    # Use weighted sampling for balanced training
    sample_weights = train_dataset.get_sample_weights()
    sampler = WeightedRandomSampler(
        weights=sample_weights,
        num_samples=len(sample_weights),
        replacement=True
    )
    
    train_loader = DataLoader(
        train_dataset, 
        batch_size=BATCH_SIZE, 
        sampler=sampler,
        num_workers=4,
        pin_memory=True
    )
    
    test_loader = DataLoader(
        test_dataset, 
        batch_size=BATCH_SIZE, 
        shuffle=False,
        num_workers=4,
        pin_memory=True
    )
    
    print(f"\n{'='*70}")
    print(f"Training Configuration:")
    print(f"{'='*70}")
    print(f"  Batch Size: {BATCH_SIZE}")
    print(f"  Epochs: {NUM_EPOCHS}")
    print(f"  Initial Learning Rate: {INITIAL_LR}")
    print(f"  Image Size: {IMG_SIZE}x{IMG_SIZE}")
    print(f"  Training Samples: {len(train_dataset)}")
    print(f"  Test Samples: {len(test_dataset)}")
    print(f"{'='*70}\n")
    
    # Create model
    model = create_advanced_model(NUM_CLASSES, pretrained=True).to(device)
    
    # Loss function with class weights for handling imbalance
    class_weights = train_dataset.get_class_weights().to(device)
    criterion = nn.CrossEntropyLoss(weight=class_weights)
    
    # Optimizer with weight decay for regularization
    optimizer = optim.AdamW(model.parameters(), lr=INITIAL_LR, weight_decay=0.01)
    
    # Learning rate scheduler - reduce LR on plateau
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode='max', factor=0.5, patience=5, min_lr=1e-7
    )
    
    # Training history
    history = {
        'train_loss': [],
        'train_acc': [],
        'val_loss': [],
        'val_acc': []
    }
    
    best_val_acc = 0
    best_epoch = 0
    patience_counter = 0
    early_stop_patience = 15
    
    print("\n" + "="*70)
    print("  STARTING TRAINING")
    print("="*70 + "\n")
    
    # Training loop
    for epoch in range(1, NUM_EPOCHS + 1):
        print(f"\nEpoch {epoch}/{NUM_EPOCHS}")
        print("-" * 70)
        
        # Train
        train_loss, train_acc = train_one_epoch(
            model, train_loader, criterion, optimizer, device, epoch
        )
        
        # Evaluate
        val_loss, val_acc, val_preds, val_labels, val_probs = evaluate(
            model, test_loader, criterion, device, 'Validation'
        )
        
        # Update learning rate
        scheduler.step(val_acc)
        
        # Save history
        history['train_loss'].append(train_loss)
        history['train_acc'].append(train_acc)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)
        
        # Print epoch summary
        print(f"\nEpoch {epoch} Summary:")
        print(f"  Train Loss: {train_loss:.4f} | Train Acc: {train_acc:.2f}%")
        print(f"  Val Loss:   {val_loss:.4f} | Val Acc:   {val_acc:.2f}%")
        print(f"  Current LR: {optimizer.param_groups[0]['lr']:.2e}")
        
        # Save best model
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_epoch = epoch
            patience_counter = 0
            
            # Save model checkpoint
            checkpoint = {
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'val_acc': val_acc,
                'val_loss': val_loss,
                'train_acc': train_acc,
                'class_to_idx': train_dataset.class_to_idx
            }
            torch.save(checkpoint, OUTPUT_DIR / 'best_model.pth')
            
            print(f"  [OK] NEW BEST MODEL SAVED! Validation Accuracy: {val_acc:.2f}%")
            
            if val_acc >= 95.0:
                print(f"  [TARGET] ACHIEVED: {val_acc:.2f}% >= 95%!")
        else:
            patience_counter += 1
            print(f"  No improvement. Patience: {patience_counter}/{early_stop_patience}")
        
        print(f"  Best Val Acc: {best_val_acc:.2f}% (Epoch {best_epoch})")
        
        # Early stopping
        if patience_counter >= early_stop_patience:
            print(f"\n⚠ Early stopping triggered after {epoch} epochs")
            break
    
    print("\n" + "="*70)
    print("  TRAINING COMPLETED!")
    print("="*70)
    print(f"\nBest Validation Accuracy: {best_val_acc:.2f}% (Epoch {best_epoch})")
    
    if best_val_acc >= 95.0:
        print(f"[SUCCESS] Achieved target of >95% accuracy!")
    else:
        print(f"Note: Did not reach 95% target. Best: {best_val_acc:.2f}%")
        print("Consider: More epochs, data augmentation, or hyperparameter tuning")
    
    # Load best model for final evaluation
    print("\n" + "="*70)
    print("  FINAL EVALUATION WITH BEST MODEL")
    print("="*70 + "\n")
    
    checkpoint = torch.load(OUTPUT_DIR / 'best_model.pth')
    model.load_state_dict(checkpoint['model_state_dict'])
    
    _, final_acc, final_preds, final_labels, final_probs = evaluate(
        model, test_loader, criterion, device, 'Final Test'
    )
    
    # Generate classification report
    class_names = list(train_dataset.class_to_idx.keys())
    report = classification_report(
        final_labels, final_preds,
        target_names=class_names,
        output_dict=True,
        zero_division=0
    )
    
    print("\n" + "="*70)
    print("  DETAILED CLASSIFICATION REPORT")
    print("="*70)
    print(classification_report(final_labels, final_preds, 
                                target_names=class_names, zero_division=0))
    
    # Generate all visualizations
    print("\n" + "="*70)
    print("  GENERATING VISUALIZATIONS")
    print("="*70 + "\n")
    
    plot_training_history(
        history['train_loss'], history['train_acc'],
        history['val_loss'], history['val_acc'],
        OUTPUT_DIR
    )
    
    plot_confusion_matrix(final_labels, final_preds, class_names, OUTPUT_DIR, 'Test')
    plot_per_class_metrics(report, class_names, OUTPUT_DIR)
    
    # Save training log
    save_training_log(history, OUTPUT_DIR)
    
    # Save final metrics
    final_metrics = {
        'best_epoch': best_epoch,
        'best_validation_accuracy': float(best_val_acc),
        'final_test_accuracy': float(final_acc),
        'total_epochs_trained': epoch,
        'target_achieved': bool(best_val_acc >= 95.0),
        'model_architecture': 'EfficientNetV2-M',
        'image_size': IMG_SIZE,
        'batch_size': BATCH_SIZE,
        'initial_learning_rate': INITIAL_LR,
        'device': str(device),
        'gpu_name': torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU',
        'classification_report': report,
        'class_mapping': train_dataset.class_to_idx,
        'training_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    
    with open(OUTPUT_DIR / 'final_metrics.json', 'w') as f:
        json.dump(final_metrics, f, indent=2)
    
    print(f"[OK] Final metrics saved: {OUTPUT_DIR / 'final_metrics.json'}")
    
    print("\n" + "="*70)
    print("  ALL OUTPUTS SAVED SUCCESSFULLY!")
    print("="*70)
    print(f"\nOutput Directory: {OUTPUT_DIR.absolute()}")
    print("\nGenerated Files:")
    print("  [IMG] training_history.png      - Training curves")
    print("  [IMG] confusion_matrix_test.png - Classification performance")
    print("  [IMG] per_class_metrics.png     - Detailed metrics visualization")
    print("  [MODEL] best_model.pth            - Trained model checkpoint")
    print("  [CSV] training_log.csv          - Epoch-by-epoch training log")
    print("  [JSON] final_metrics.json        - Complete training summary")
    
    print(f"\n{'='*70}")
    print(f"  FINAL RESULTS")
    print(f"{'='*70}")
    print(f"  Best Validation Accuracy: {best_val_acc:.2f}%")
    print(f"  Final Test Accuracy:      {final_acc:.2f}%")
    print(f"  Target (>95%):            {'[ACHIEVED]' if best_val_acc >= 95.0 else '[Not reached]'}")
    print(f"{'='*70}\n")
    
    print("[COMPLETE] Training finished! Your model is ready to use.")
    print(f"Model saved at: {OUTPUT_DIR / 'best_model.pth'}\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[WARNING] Training interrupted by user")
    except Exception as e:
        print(f"\n\n[ERROR] Error during training: {e}")
        import traceback
        traceback.print_exc()
e
