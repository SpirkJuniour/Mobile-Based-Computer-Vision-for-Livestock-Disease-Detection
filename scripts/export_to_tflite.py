#!/usr/bin/env python3
"""
Export trained model to TensorFlow Lite
Quick script to convert the trained model
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2
from pathlib import Path
import json
import datetime
import os

# Configuration
class Config:
    IMAGE_SIZE = (224, 224)
    NUM_CLASSES = 11
    DROPOUT_RATE = 0.4
    L2_REG = 0.0001
    OUTPUT_DIR = Path(__file__).parent / "training_outputs"
    WEIGHTS_PATH = OUTPUT_DIR / "best_model_weights.weights.h5"
    MODEL_PATH = OUTPUT_DIR / "livestock_disease_model.h5"
    TFLITE_PATH = OUTPUT_DIR / "livestock_disease_model.tflite"
    METADATA_PATH = OUTPUT_DIR / "model_metadata.json"

def create_model(num_classes, config):
    """Recreate the model architecture"""
    base_model = MobileNetV2(
        include_top=False,
        weights='imagenet',
        input_shape=(*config.IMAGE_SIZE, 3),
        pooling='avg'
    )
    
    for layer in base_model.layers[:-20]:
        layer.trainable = False
    
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
    
    return model

def main():
    print("=" * 70)
    print("Exporting Trained Model to TensorFlow Lite")
    print("=" * 70)
    
    config = Config()
    
    # Check if weights exist
    if not config.WEIGHTS_PATH.exists():
        print(f"\n[ERROR] Weights not found: {config.WEIGHTS_PATH}")
        print("Please train the model first.")
        return
    
    print(f"\n[*] Loading model architecture...")
    model = create_model(config.NUM_CLASSES, config)
    
    print(f"[*] Loading trained weights...")
    model.load_weights(str(config.WEIGHTS_PATH))
    print(f"[OK] Weights loaded successfully")
    
    # Save full model
    print(f"\n[*] Saving full model...")
    model.save(str(config.MODEL_PATH))
    print(f"[OK] Saved to: {config.MODEL_PATH}")
    
    # Convert to TFLite
    print(f"\n[*] Converting to TensorFlow Lite...")
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        
        with open(config.TFLITE_PATH, 'wb') as f:
            f.write(tflite_model)
        
        h5_size = os.path.getsize(config.MODEL_PATH) / (1024 * 1024)
        tflite_size = os.path.getsize(config.TFLITE_PATH) / (1024 * 1024)
        
        print(f"[OK] TFLite model saved!")
        print(f"    H5 model: {h5_size:.2f} MB")
        print(f"    TFLite model: {tflite_size:.2f} MB")
        print(f"    Size reduction: {((h5_size - tflite_size) / h5_size * 100):.1f}%")
        print(f"    Location: {config.TFLITE_PATH}")
    except Exception as e:
        print(f"[ERROR] TFLite conversion failed: {e}")
        return
    
    # Create metadata
    print(f"\n[*] Creating metadata...")
    class_names = [' (BRD)', ' Bovine', ' Contagious', ' Dermatitis', ' Disease', 
                   ' Ecthym', ' Respiratory', ' Unlabeled', ' healthy', ' lumpy', ' skin']
    
    metadata = {
        'model_name': 'Livestock Disease Detection',
        'model_type': 'mobilenetv2',
        'version': '1.0.0',
        'created_at': datetime.datetime.now().isoformat(),
        'num_classes': config.NUM_CLASSES,
        'classes': class_names,
        'input_shape': [*config.IMAGE_SIZE, 3],
        'image_size': config.IMAGE_SIZE,
        'normalization': 'rescale_0_1',
        'final_accuracy': 84.95,  # From training
        'notes': 'Trained on 567 images, validated on 186 images. Early stopping at epoch 15.'
    }
    
    with open(config.METADATA_PATH, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"[OK] Metadata saved to: {config.METADATA_PATH}")
    
    # Final summary
    print("\n" + "=" * 70)
    print("Export Complete!")
    print("=" * 70)
    print(f"\nFiles created:")
    print(f"  1. {config.MODEL_PATH.name} (Full Keras model)")
    print(f"  2. {config.TFLITE_PATH.name} (For Flutter app) ← Use this!")
    print(f"  3. {config.METADATA_PATH.name} (Model info)")
    print(f"\nValidation Accuracy: 84.95%")
    print(f"\nNext steps:")
    print(f"  1. Copy to Flutter:")
    print(f"     copy {config.TFLITE_PATH} assets\\models\\")
    print(f"  2. Test in your app!")
    print("\n" + "=" * 70)

if __name__ == "__main__":
    main()

