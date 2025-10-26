#!/usr/bin/env python3
"""
TensorFlow Livestock Disease Detection Model Training
High-accuracy model using transfer learning and advanced techniques
Author: MifugoCare Team
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers
from tensorflow.keras.applications import (
    EfficientNetB4, ResNet50V2, DenseNet201, InceptionResNetV2
)
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import (
    ModelCheckpoint, EarlyStopping, ReduceLROnPlateau, 
    TensorBoard, CSVLogger
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

# Configuration
class Config:
    """Training configuration"""
    # Data
    DATA_DIR = Path(__file__).parent.parent / "assets" / "unlabeled_data"
    IMAGE_SIZE = (224, 224)
    BATCH_SIZE = 32
    NUM_CLASSES = 5
    CLASS_NAMES = ['lumpy_skin', 'fmd', 'mastitis', 'healthy', 'dermatitis']
    
    # Training
    EPOCHS = 100
    INITIAL_LR = 0.001
    MIN_LR = 1e-7
    
    # Model
    DROPOUT_RATE = 0.5
    L2_REG = 0.001
    
    # Paths
    OUTPUT_DIR = Path(__file__).parent / "training_outputs"
    MODEL_PATH = OUTPUT_DIR / "livestock_disease_model.h5"
    WEIGHTS_PATH = OUTPUT_DIR / "best_model_weights.h5"
    TFLITE_PATH = OUTPUT_DIR / "livestock_disease_model.tflite"
    METADATA_PATH = OUTPUT_DIR / "model_metadata.json"
    HISTORY_PATH = OUTPUT_DIR / "training_history.csv"
    
    def __init__(self):
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

class DataGenerator:
    """Advanced data generator with augmentation"""
    
    def __init__(self, config):
        self.config = config
        
    def create_generators(self):
        """Create train, validation, and test data generators"""
        
        # Training data augmentation
        train_datagen = ImageDataGenerator(
            rescale=1./255,
            rotation_range=40,
            width_shift_range=0.3,
            height_shift_range=0.3,
            shear_range=0.3,
            zoom_range=0.3,
            horizontal_flip=True,
            vertical_flip=True,
            brightness_range=[0.6, 1.4],
            fill_mode='reflect',
            validation_split=0.2
        )
        
        # Validation data (minimal augmentation)
        val_datagen = ImageDataGenerator(
            rescale=1./255,
            validation_split=0.2
        )
        
        # Test data (no augmentation)
        test_datagen = ImageDataGenerator(rescale=1./255)
        
        # Load data
        train_generator = self._load_data_from_sources(train_datagen, subset='training')
        val_generator = self._load_data_from_sources(val_datagen, subset='validation')
        
        return train_generator, val_generator
    
    def _load_data_from_sources(self, datagen, subset='training'):
        """Load data from all available sources"""
        # Check for multiclass data
        multiclass_dir = self.config.DATA_DIR / "cattle diseases.v2i.multiclass" / "train"
        
        if multiclass_dir.exists():
            generator = datagen.flow_from_directory(
                str(multiclass_dir),
                target_size=self.config.IMAGE_SIZE,
                batch_size=self.config.BATCH_SIZE,
                class_mode='categorical',
                subset=subset,
                shuffle=(subset == 'training')
            )
            return generator
        else:
            raise ValueError(f"Data directory not found: {multiclass_dir}")

class EnsembleModel:
    """Advanced ensemble model for high accuracy"""
    
    def __init__(self, config):
        self.config = config
        
    def build_model(self):
        """Build advanced ensemble model"""
        print("\n🧠 Building advanced ensemble model...")
        
        # Input layer
        inputs = layers.Input(shape=(*self.config.IMAGE_SIZE, 3))
        
        # Build multiple backbones
        efficientnet_model = self._build_efficientnet(inputs)
        resnet_model = self._build_resnet(inputs)
        densenet_model = self._build_densenet(inputs)
        inception_model = self._build_inception_resnet(inputs)
        
        # Ensemble fusion
        ensemble = layers.concatenate([
            efficientnet_model,
            resnet_model,
            densenet_model,
            inception_model
        ])
        
        # Fusion layers
        x = layers.Dense(1024, activation='relu',
                        kernel_regularizer=keras.regularizers.l2(self.config.L2_REG))(ensemble)
        x = layers.BatchNormalization()(x)
        x = layers.Dropout(self.config.DROPOUT_RATE)(x)
        
        x = layers.Dense(512, activation='relu',
                        kernel_regularizer=keras.regularizers.l2(self.config.L2_REG))(x)
        x = layers.BatchNormalization()(x)
        x = layers.Dropout(self.config.DROPOUT_RATE)(x)
        
        x = layers.Dense(256, activation='relu',
                        kernel_regularizer=keras.regularizers.l2(self.config.L2_REG))(x)
        x = layers.BatchNormalization()(x)
        x = layers.Dropout(self.config.DROPOUT_RATE / 2)(x)
        
        # Output layer
        outputs = layers.Dense(self.config.NUM_CLASSES, activation='softmax')(x)
        
        # Create model
        model = models.Model(inputs=inputs, outputs=outputs, name='livestock_ensemble')
        
        return model
    
    def _build_efficientnet(self, inputs):
        """Build EfficientNet branch"""
        base = EfficientNetB4(
            include_top=False,
            weights='imagenet',
            input_tensor=inputs,
            pooling='avg'
        )
        # Fine-tune last layers
        for layer in base.layers[:-30]:
            layer.trainable = False
        return base.output
    
    def _build_resnet(self, inputs):
        """Build ResNet branch"""
        base = ResNet50V2(
            include_top=False,
            weights='imagenet',
            input_tensor=inputs,
            pooling='avg'
        )
        for layer in base.layers[:-30]:
            layer.trainable = False
        return base.output
    
    def _build_densenet(self, inputs):
        """Build DenseNet branch"""
        base = DenseNet201(
            include_top=False,
            weights='imagenet',
            input_tensor=inputs,
            pooling='avg'
        )
        for layer in base.layers[:-30]:
            layer.trainable = False
        return base.output
    
    def _build_inception_resnet(self, inputs):
        """Build InceptionResNet branch"""
        base = InceptionResNetV2(
            include_top=False,
            weights='imagenet',
            input_tensor=inputs,
            pooling='avg'
        )
        for layer in base.layers[:-30]:
            layer.trainable = False
        return base.output

class ModelTrainer:
    """Model training orchestrator"""
    
    def __init__(self, config):
        self.config = config
        self.model = None
        self.history = None
        
    def train(self, model, train_gen, val_gen):
        """Train the model with advanced techniques"""
        print("\n🎯 Starting training...")
        print(f"Target: High accuracy (90%+)")
        print(f"Epochs: {self.config.EPOCHS}")
        print(f"Batch size: {self.config.BATCH_SIZE}")
        print("=" * 70)
        
        # Compile model with advanced optimizer
        optimizer = optimizers.AdamW(
            learning_rate=self.config.INITIAL_LR,
            weight_decay=0.01
        )
        
        model.compile(
            optimizer=optimizer,
            loss='categorical_crossentropy',
            metrics=['accuracy', 
                    keras.metrics.Precision(),
                    keras.metrics.Recall(),
                    keras.metrics.AUC()]
        )
        
        # Callbacks
        callbacks = [
            # Save best model
            ModelCheckpoint(
                str(self.config.WEIGHTS_PATH),
                monitor='val_accuracy',
                save_best_only=True,
                save_weights_only=True,
                mode='max',
                verbose=1
            ),
            
            # Early stopping
            EarlyStopping(
                monitor='val_accuracy',
                patience=15,
                restore_best_weights=True,
                mode='max',
                verbose=1
            ),
            
            # Learning rate reduction
            ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.2,
                patience=5,
                min_lr=self.config.MIN_LR,
                verbose=1
            ),
            
            # TensorBoard
            TensorBoard(
                log_dir=str(self.config.OUTPUT_DIR / 'tensorboard_logs'),
                histogram_freq=1
            ),
            
            # CSV Logger
            CSVLogger(str(self.config.HISTORY_PATH))
        ]
        
        # Train model
        self.history = model.fit(
            train_gen,
            validation_data=val_gen,
            epochs=self.config.EPOCHS,
            callbacks=callbacks,
            verbose=1
        )
        
        self.model = model
        return self.history
    
    def evaluate(self, val_gen):
        """Evaluate model and generate reports"""
        print("\n📊 Evaluating model...")
        
        # Load best weights
        self.model.load_weights(str(self.config.WEIGHTS_PATH))
        
        # Evaluate
        results = self.model.evaluate(val_gen, verbose=1)
        
        print(f"\nValidation Accuracy: {results[1]*100:.2f}%")
        
        # Get predictions
        val_gen.reset()
        predictions = self.model.predict(val_gen, verbose=1)
        y_pred = np.argmax(predictions, axis=1)
        y_true = val_gen.classes
        
        # Classification report
        print("\n📈 Classification Report:")
        print(classification_report(
            y_true, y_pred,
            target_names=self.config.CLASS_NAMES
        ))
        
        # Confusion matrix
        cm = confusion_matrix(y_true, y_pred)
        self._plot_confusion_matrix(cm)
        
        # Plot training history
        self._plot_training_history()
        
        return results[1] * 100  # Return accuracy percentage
    
    def _plot_confusion_matrix(self, cm):
        """Plot confusion matrix"""
        plt.figure(figsize=(10, 8))
        sns.heatmap(
            cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=self.config.CLASS_NAMES,
            yticklabels=self.config.CLASS_NAMES
        )
        plt.title('Confusion Matrix - Livestock Disease Detection')
        plt.xlabel('Predicted')
        plt.ylabel('Actual')
        plt.tight_layout()
        plt.savefig(
            str(self.config.OUTPUT_DIR / 'confusion_matrix.png'),
            dpi=300, bbox_inches='tight'
        )
        print(f"✅ Confusion matrix saved")
    
    def _plot_training_history(self):
        """Plot training history"""
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        
        # Accuracy
        axes[0, 0].plot(self.history.history['accuracy'], label='Train')
        axes[0, 0].plot(self.history.history['val_accuracy'], label='Validation')
        axes[0, 0].set_title('Model Accuracy')
        axes[0, 0].set_xlabel('Epoch')
        axes[0, 0].set_ylabel('Accuracy')
        axes[0, 0].legend()
        axes[0, 0].grid(True)
        
        # Loss
        axes[0, 1].plot(self.history.history['loss'], label='Train')
        axes[0, 1].plot(self.history.history['val_loss'], label='Validation')
        axes[0, 1].set_title('Model Loss')
        axes[0, 1].set_xlabel('Epoch')
        axes[0, 1].set_ylabel('Loss')
        axes[0, 1].legend()
        axes[0, 1].grid(True)
        
        # Precision
        axes[1, 0].plot(self.history.history['precision'], label='Train')
        axes[1, 0].plot(self.history.history['val_precision'], label='Validation')
        axes[1, 0].set_title('Model Precision')
        axes[1, 0].set_xlabel('Epoch')
        axes[1, 0].set_ylabel('Precision')
        axes[1, 0].legend()
        axes[1, 0].grid(True)
        
        # Recall
        axes[1, 1].plot(self.history.history['recall'], label='Train')
        axes[1, 1].plot(self.history.history['val_recall'], label='Validation')
        axes[1, 1].set_title('Model Recall')
        axes[1, 1].set_xlabel('Epoch')
        axes[1, 1].set_ylabel('Recall')
        axes[1, 1].legend()
        axes[1, 1].grid(True)
        
        plt.tight_layout()
        plt.savefig(
            str(self.config.OUTPUT_DIR / 'training_history.png'),
            dpi=300, bbox_inches='tight'
        )
        print(f"✅ Training history plots saved")
    
    def save_model(self):
        """Save complete model"""
        print("\n💾 Saving model...")
        
        # Save full model
        self.model.save(str(self.config.MODEL_PATH))
        print(f"✅ Model saved to: {self.config.MODEL_PATH}")
        
        # Convert to TFLite
        self._convert_to_tflite()
        
        # Save metadata
        self._save_metadata()
    
    def _convert_to_tflite(self):
        """Convert model to TensorFlow Lite"""
        print("\n🔄 Converting to TensorFlow Lite...")
        
        try:
            # Create converter
            converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
            
            # Optimizations
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]
            
            # Convert
            tflite_model = converter.convert()
            
            # Save
            with open(self.config.TFLITE_PATH, 'wb') as f:
                f.write(tflite_model)
            
            print(f"✅ TFLite model saved to: {self.config.TFLITE_PATH}")
            
            # Get size info
            h5_size = os.path.getsize(self.config.MODEL_PATH) / (1024 * 1024)
            tflite_size = os.path.getsize(self.config.TFLITE_PATH) / (1024 * 1024)
            
            print(f"   H5 model size: {h5_size:.2f} MB")
            print(f"   TFLite model size: {tflite_size:.2f} MB")
            print(f"   Size reduction: {((h5_size - tflite_size) / h5_size * 100):.1f}%")
            
        except Exception as e:
            print(f"❌ TFLite conversion failed: {e}")
            print("   You can convert manually later using convert_to_tflite.py")
    
    def _save_metadata(self):
        """Save model metadata"""
        metadata = {
            'model_name': 'Livestock Disease Detection',
            'model_type': 'ensemble_efficientnet_resnet_densenet_inception',
            'version': '1.0.0',
            'created_at': datetime.datetime.now().isoformat(),
            'num_classes': self.config.NUM_CLASSES,
            'classes': self.config.CLASS_NAMES,
            'input_shape': [*self.config.IMAGE_SIZE, 3],
            'image_size': self.config.IMAGE_SIZE,
            'normalization': 'rescale_1_255',
            'accuracy_target': 90.0,
            'training_epochs': self.config.EPOCHS,
            'batch_size': self.config.BATCH_SIZE,
        }
        
        with open(self.config.METADATA_PATH, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        print(f"✅ Metadata saved to: {self.config.METADATA_PATH}")

def main():
    """Main training pipeline"""
    print("=" * 70)
    print("🚀 TensorFlow Livestock Disease Detection Model Training")
    print("   Target: High Accuracy (90%+)")
    print("=" * 70)
    
    # Check TensorFlow
    print(f"\nTensorFlow version: {tf.__version__}")
    print(f"GPU available: {tf.config.list_physical_devices('GPU')}")
    
    # Setup
    config = Config()
    
    # Check data
    if not config.DATA_DIR.exists():
        print(f"\n❌ Error: Data directory not found: {config.DATA_DIR}")
        print("   Please ensure training data is available in assets/unlabeled_data/")
        return
    
    # Create data generators
    print("\n📁 Loading data...")
    data_gen = DataGenerator(config)
    train_gen, val_gen = data_gen.create_generators()
    
    print(f"✅ Training samples: {train_gen.samples}")
    print(f"✅ Validation samples: {val_gen.samples}")
    print(f"✅ Classes: {train_gen.class_indices}")
    
    # Build model
    model_builder = EnsembleModel(config)
    model = model_builder.build_model()
    
    print(f"\n📊 Model summary:")
    print(f"   Total parameters: {model.count_params():,}")
    print(f"   Trainable parameters: {sum([tf.size(w).numpy() for w in model.trainable_weights]):,}")
    
    # Train model
    trainer = ModelTrainer(config)
    trainer.train(model, train_gen, val_gen)
    
    # Evaluate
    accuracy = trainer.evaluate(val_gen)
    
    # Save model
    trainer.save_model()
    
    # Final report
    print("\n" + "=" * 70)
    print("🎉 Training Complete!")
    print("=" * 70)
    print(f"Final Validation Accuracy: {accuracy:.2f}%")
    
    if accuracy >= 90.0:
        print("✅ TARGET ACHIEVED: 90%+ accuracy!")
        print("🎯 Model is ready for deployment")
    else:
        print(f"⚠️  Target not reached. Current: {accuracy:.2f}%")
        print("💡 Consider:")
        print("   - Training for more epochs")
        print("   - Adding more training data")
        print("   - Adjusting hyperparameters")
    
    print(f"\n📁 All outputs saved to: {config.OUTPUT_DIR}")
    print(f"   - Model: {config.MODEL_PATH.name}")
    print(f"   - TFLite: {config.TFLITE_PATH.name}")
    print(f"   - Metadata: {config.METADATA_PATH.name}")
    print(f"   - Weights: {config.WEIGHTS_PATH.name}")
    print("\n🚀 Ready for Flutter integration!")

if __name__ == "__main__":
    main()

