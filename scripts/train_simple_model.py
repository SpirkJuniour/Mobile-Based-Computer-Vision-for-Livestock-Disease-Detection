#!/usr/bin/env python3
"""
Simple TensorFlow Livestock Disease Detection Model Training
Works with CSV-labeled dataset structure
Author: MifugoCare Team
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.callbacks import (
    ModelCheckpoint, EarlyStopping, ReduceLROnPlateau, CSVLogger
)
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
from pathlib import Path
import json
import datetime
import os
from PIL import Image

# Configuration
class Config:
    """Training configuration"""
    # Data
    DATA_DIR = Path(__file__).parent.parent / "assets" / "unlabeled_data" / "cattle diseases.v2i.multiclass"
    IMAGE_SIZE = (224, 224)
    BATCH_SIZE = 32
    EPOCHS = 50
    INITIAL_LR = 0.001
    MIN_LR = 1e-7
    
    # Model
    DROPOUT_RATE = 0.4
    L2_REG = 0.0001
    
    # Paths
    OUTPUT_DIR = Path(__file__).parent / "training_outputs"
    MODEL_PATH = OUTPUT_DIR / "livestock_disease_model.h5"
    WEIGHTS_PATH = OUTPUT_DIR / "best_model_weights.weights.h5"  # TF 2.20+ requires .weights.h5
    TFLITE_PATH = OUTPUT_DIR / "livestock_disease_model.tflite"
    METADATA_PATH = OUTPUT_DIR / "model_metadata.json"
    HISTORY_PATH = OUTPUT_DIR / "training_history.csv"
    
    def __init__(self):
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def load_dataset(config, split='train'):
    """Load dataset from CSV and images"""
    print(f"\n[*] Loading {split} dataset...")
    
    # Load CSV
    data_path = config.DATA_DIR / split
    csv_path = data_path / "_classes.csv"
    
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")
    
    df = pd.read_csv(csv_path)
    print(f"   Found {len(df)} images")
    
    # Get class columns (all except filename)
    class_columns = [col for col in df.columns if col != 'filename']
    print(f"   Classes: {class_columns}")
    
    # Create primary class labels (take the first positive class)
    def get_primary_class(row):
        for i, col in enumerate(class_columns):
            if row[col] == 1:
                return i
        return 0  # Default to first class if no label
    
    df['primary_class'] = df.apply(get_primary_class, axis=1)
    
    # Load images and labels
    images = []
    labels = []
    valid_files = []
    
    print("   Loading images...")
    for idx, row in df.iterrows():
        img_path = data_path / row['filename']
        if img_path.exists():
            try:
                img = Image.open(img_path).convert('RGB')
                img = img.resize(config.IMAGE_SIZE)
                img_array = np.array(img) / 255.0  # Normalize
                images.append(img_array)
                labels.append(row['primary_class'])
                valid_files.append(row['filename'])
                
                if (idx + 1) % 100 == 0:
                    print(f"      Loaded {idx + 1}/{len(df)} images")
            except Exception as e:
                print(f"      Error loading {img_path}: {e}")
        else:
            print(f"      File not found: {img_path}")
    
    print(f"   [OK] Successfully loaded {len(images)} images")
    
    # Convert to numpy arrays
    X = np.array(images, dtype=np.float32)
    y = np.array(labels, dtype=np.int32)
    
    # Convert labels to one-hot
    num_classes = len(class_columns)
    y_one_hot = keras.utils.to_categorical(y, num_classes)
    
    return X, y_one_hot, class_columns, valid_files

def create_model(num_classes, config):
    """Create a simple but effective model"""
    print("\n[*] Building model...")
    
    # Use MobileNetV2 as base model (lightweight and compatible)
    base_model = MobileNetV2(
        include_top=False,
        weights='imagenet',
        input_shape=(*config.IMAGE_SIZE, 3),
        pooling='avg'
    )
    
    # Freeze early layers
    for layer in base_model.layers[:-20]:
        layer.trainable = False
    
    # Create model with Sequential API
    model = models.Sequential([
        base_model,
        layers.Dropout(config.DROPOUT_RATE),
        layers.Dense(256, activation='relu',
                    kernel_regularizer=keras.regularizers.l2(config.L2_REG)),
        layers.BatchNormalization(),
        layers.Dropout(config.DROPOUT_RATE / 2),
        layers.Dense(128, activation='relu',
                    kernel_regularizer=keras.regularizers.l2(config.L2_REG)),
        layers.BatchNormalization(),
        layers.Dense(num_classes, activation='softmax')
    ], name='livestock_classifier')
    
    print(f"   Total parameters: {model.count_params():,}")
    
    return model

def train_model(model, X_train, y_train, X_val, y_val, config):
    """Train the model"""
    print("\n[*] Starting training...")
    print(f"   Epochs: {config.EPOCHS}")
    print(f"   Batch size: {config.BATCH_SIZE}")
    print(f"   Training samples: {len(X_train)}")
    print(f"   Validation samples: {len(X_val)}")
    print("=" * 70)
    
    # Compile model
    optimizer = optimizers.Adam(learning_rate=config.INITIAL_LR)
    
    model.compile(
        optimizer=optimizer,
        loss='categorical_crossentropy',
        metrics=['accuracy', keras.metrics.Precision(), keras.metrics.Recall()]
    )
    
    # Callbacks
    callbacks = [
        ModelCheckpoint(
            str(config.WEIGHTS_PATH),
            monitor='val_accuracy',
            save_best_only=True,
            save_weights_only=True,
            mode='max',
            verbose=1
        ),
        EarlyStopping(
            monitor='val_accuracy',
            patience=10,
            restore_best_weights=True,
            mode='max',
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.2,
            patience=5,
            min_lr=config.MIN_LR,
            verbose=1
        ),
        CSVLogger(str(config.HISTORY_PATH))
    ]
    
    # Train model
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=config.EPOCHS,
        batch_size=config.BATCH_SIZE,
        callbacks=callbacks,
        verbose=1
    )
    
    return history

def evaluate_model(model, X_val, y_val, class_names, config):
    """Evaluate model and generate reports"""
    print("\n[*] Evaluating model...")
    
    # Load best weights
    model.load_weights(str(config.WEIGHTS_PATH))
    
    # Evaluate
    results = model.evaluate(X_val, y_val, verbose=1)
    accuracy = results[1] * 100
    
    print(f"\n[OK] Validation Accuracy: {accuracy:.2f}%")
    
    # Get predictions
    predictions = model.predict(X_val, verbose=1)
    y_pred = np.argmax(predictions, axis=1)
    y_true = np.argmax(y_val, axis=1)
    
    # Classification report (only for classes present in validation set)
    print("\n[*] Classification Report:")
    unique_classes = sorted(set(y_true) | set(y_pred))
    class_names_present = [class_names[i] for i in unique_classes]
    print(classification_report(y_true, y_pred, labels=unique_classes, target_names=class_names_present))
    
    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=class_names, yticklabels=class_names)
    plt.title('Confusion Matrix - Livestock Disease Detection')
    plt.xlabel('Predicted')
    plt.ylabel('Actual')
    plt.tight_layout()
    plt.savefig(str(config.OUTPUT_DIR / 'confusion_matrix.png'),
                dpi=300, bbox_inches='tight')
    print(f"[OK] Confusion matrix saved")
    
    return accuracy

def save_model(model, config, class_names, history):
    """Save complete model and metadata"""
    print("\n[*] Saving model...")
    
    # Save full model
    model.save(str(config.MODEL_PATH))
    print(f"[OK] Model saved to: {config.MODEL_PATH}")
    
    # Convert to TFLite
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        
        with open(config.TFLITE_PATH, 'wb') as f:
            f.write(tflite_model)
        
        h5_size = os.path.getsize(config.MODEL_PATH) / (1024 * 1024)
        tflite_size = os.path.getsize(config.TFLITE_PATH) / (1024 * 1024)
        
        print(f"[OK] TFLite model saved to: {config.TFLITE_PATH}")
        print(f"   H5 model size: {h5_size:.2f} MB")
        print(f"   TFLite model size: {tflite_size:.2f} MB")
        print(f"   Size reduction: {((h5_size - tflite_size) / h5_size * 100):.1f}%")
    except Exception as e:
        print(f"[WARN] TFLite conversion warning: {e}")
    
    # Save metadata
    metadata = {
        'model_name': 'Livestock Disease Detection',
        'model_type': 'mobilenetv2',
        'version': '1.0.0',
        'created_at': datetime.datetime.now().isoformat(),
        'num_classes': len(class_names),
        'classes': class_names,
        'input_shape': [*config.IMAGE_SIZE, 3],
        'image_size': config.IMAGE_SIZE,
        'normalization': 'rescale_0_1',
        'training_epochs': config.EPOCHS,
        'batch_size': config.BATCH_SIZE,
        'final_accuracy': float(max(history.history['val_accuracy'])) * 100
    }
    
    with open(config.METADATA_PATH, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"[OK] Metadata saved to: {config.METADATA_PATH}")

def main():
    """Main training pipeline"""
    print("=" * 70)
    print("Livestock Disease Detection Model Training")
    print("Simple and Effective Approach")
    print("=" * 70)
    
    # Check TensorFlow
    print(f"\nTensorFlow version: {tf.__version__}")
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print(f"GPU available: {len(gpus)} device(s)")
    else:
        print("GPU: Not available (using CPU)")
    
    # Setup
    config = Config()
    
    # Check data
    if not config.DATA_DIR.exists():
        print(f"\n[ERROR] Data directory not found: {config.DATA_DIR}")
        return
    
    # Load datasets
    X_train, y_train, class_names, train_files = load_dataset(config, 'train')
    X_val, y_val, _, val_files = load_dataset(config, 'valid')
    
    num_classes = len(class_names)
    print(f"\n[*] Dataset summary:")
    print(f"   Classes: {num_classes}")
    print(f"   Training samples: {len(X_train)}")
    print(f"   Validation samples: {len(X_val)}")
    
    # Create model
    model = create_model(num_classes, config)
    
    # Train model
    history = train_model(model, X_train, y_train, X_val, y_val, config)
    
    # Evaluate
    accuracy = evaluate_model(model, X_val, y_val, class_names, config)
    
    # Save model
    save_model(model, config, class_names, history)
    
    # Final report
    print("\n" + "=" * 70)
    print("Training Complete!")
    print("=" * 70)
    print(f"Final Validation Accuracy: {accuracy:.2f}%")
    print(f"\n[*] All outputs saved to: {config.OUTPUT_DIR}")
    print(f"   - Model: {config.MODEL_PATH.name}")
    print(f"   - TFLite: {config.TFLITE_PATH.name}")
    print(f"   - Metadata: {config.METADATA_PATH.name}")
    print(f"   - Weights: {config.WEIGHTS_PATH.name}")
    print("\nReady for Flutter integration!")
    
    # Copy to assets if desired
    assets_model_dir = Path(__file__).parent.parent / "assets" / "models"
    assets_model_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"\n[*] To use in your Flutter app, copy:")
    print(f"   {config.TFLITE_PATH}")
    print(f"   to: {assets_model_dir}/")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[WARN] Training interrupted by user")
    except Exception as e:
        print(f"\n\n[ERROR] Error: {e}")
        import traceback
        traceback.print_exc()

