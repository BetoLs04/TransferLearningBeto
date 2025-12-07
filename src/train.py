"""
Training script using MobileNetV2 with relative paths and performance metrics.
Includes Accuracy and F1-score during training, and Precision/Recall after training.

@author: Lazaro Roberto Luevano
@date: 2025-12-07
@version: 1.2
"""

from pathlib import Path
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model
from sklearn.metrics import precision_score, recall_score, f1_score as sk_f1


# Custom F1-score compatible with sparse labels
def f1_metric(y_true, y_pred):
    y_true = tf.one_hot(tf.cast(y_true, tf.int32), depth=tf.shape(y_pred)[1])
    y_pred = tf.round(y_pred)

    tp = tf.reduce_sum(tf.cast(y_true * y_pred, tf.float32), axis=0)
    fp = tf.reduce_sum(tf.cast((1 - y_true) * y_pred, tf.float32), axis=0)
    fn = tf.reduce_sum(tf.cast(y_true * (1 - y_pred), tf.float32), axis=0)

    precision = tp / (tp + fp + 1e-8)
    recall = tp / (tp + fn + 1e-8)

    f1 = 2 * precision * recall / (precision + recall + 1e-8)
    return tf.reduce_mean(f1)


def main():
    print("\n=== Training MobileNetV2 model ===\n")

    BASE_DIR = Path(__file__).parent
    TRAIN_DIR = BASE_DIR / ".." / "dataset" / "train"
    VAL_DIR = BASE_DIR / ".." / "dataset" / "val"

    # Load datasets
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

    class_count = len(train_ds.class_names)

    # Load MobileNetV2
    base_model = MobileNetV2(
        weights="imagenet",
        include_top=False,
        input_shape=(224, 224, 3)
    )
    base_model.trainable = False

    # Classifier
    x = GlobalAveragePooling2D()(base_model.output)
    x = Dense(64, activation="relu")(x)
    output = Dense(class_count, activation="softmax")(x)

    model = Model(inputs=base_model.input, outputs=output)

    # Compile model (safe metrics)
    model.compile(
        optimizer="adam",
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy", f1_metric]
    )

    # Train model
    model.fit(train_ds, validation_data=val_ds, epochs=5)

    # === Evaluate precision and recall after training ===
    y_true = []
    y_pred = []

    for images, labels in val_ds:
        preds = model.predict(images)
        preds = preds.argmax(axis=1)

        y_true.extend(labels.numpy())
        y_pred.extend(preds)

    precision = precision_score(y_true, y_pred, average="macro")
    recall = recall_score(y_true, y_pred, average="macro")
    f1 = sk_f1(y_true, y_pred, average="macro")

    print("\nFinal Evaluation (Validation Set)")
    print(f"Precision: {precision:.4f}")
    print(f"Recall: {recall:.4f}")
    print(f"F1-score: {f1:.4f}\n")

    # Save model
    MODEL_DIR = BASE_DIR / ".." / "models"
    MODEL_DIR.mkdir(exist_ok=True)
    model.save(MODEL_DIR / "beverage_classifier.h5")

    print("Model saved at /models/beverage_classifier.h5\n")


if __name__ == "__main__":
    main()
