"""
Basic training script using MobileNetV2 with relative paths.

@author: Lazaro Roberto Luevano Serna
@date: 2025-12-04
@version: 1.0
"""

from pathlib import Path
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model

def main():
    print("\n=== Training model with MobileNetV2 ===\n")
    
    BASE_DIR = Path(__file__).parent

    # Relative dataset folders
    TRAIN_DIR = BASE_DIR / ".." / "dataset" / "train"
    VAL_DIR = BASE_DIR / ".." / "dataset" / "val"

    # Load dataset
    train_ds = tf.keras.utils.image_dataset_from_directory(
        TRAIN_DIR,
        image_size=(224, 224),
        batch_size=16
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        VAL_DIR,
        image_size=(224, 224),
        batch_size=16
    )

    # Load MobileNetV2
    base_model = MobileNetV2(weights="imagenet", include_top=False, input_shape=(224, 224, 3))
    base_model.trainable = False

    # Add classifier
    x = GlobalAveragePooling2D()(base_model.output)
    x = Dense(64, activation="relu")(x)
    output = Dense(len(train_ds.class_names), activation="softmax")(x)

    model = Model(inputs=base_model.input, outputs=output)

    model.compile(optimizer="adam",
                  loss="sparse_categorical_crossentropy",
                  metrics=["accuracy"])

    # Train model
    model.fit(train_ds, validation_data=val_ds, epochs=5)

    # Save model
    MODEL_DIR = BASE_DIR / ".." / "models"
    MODEL_DIR.mkdir(exist_ok=True)
    model.save(MODEL_DIR / "beverage_classifier.h5")

    print("\nModel saved in /models/beverage_classifier.h5")

if __name__ == "__main__":
    main()
