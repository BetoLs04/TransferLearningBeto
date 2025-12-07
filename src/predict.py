"""
Basic prediction script for MobileNetV2 classifier.
Loads a trained model and predicts the class of an input image.

@author: Lazaro Roberto Luevano Serna   
@date: 2025-12-04
@version: 1.0
"""

from pathlib import Path
import tensorflow as tf
import numpy as np


def load_model_and_classes(base_dir):
    """Load model and class names based on dataset directory."""
    model_path = base_dir / ".." / "models" / "beverage_classifier.h5"
    dataset_train = base_dir / ".." / "dataset" / "train"

    if not model_path.exists():
        raise FileNotFoundError(f"Model not found at: {model_path}")

    if not dataset_train.exists():
        raise FileNotFoundError(f"Dataset folder not found at: {dataset_train}")

    print("Loading model...")
    model = tf.keras.models.load_model(model_path)

    print("Loading class names...")
    class_names = sorted([d.name for d in dataset_train.iterdir() if d.is_dir()])

    return model, class_names


def preprocess_image(img_path):
    """Load and preprocess image for MobileNetV2."""
    img = tf.keras.preprocessing.image.load_img(img_path, target_size=(224, 224))
    img_array = tf.keras.preprocessing.image.img_to_array(img)

    img_array = tf.keras.applications.mobilenet_v2.preprocess_input(img_array)
    img_array = np.expand_dims(img_array, axis=0)  # (1,224,224,3)

    return img_array


def predict_image(model, class_names, img_array):
    """Generate prediction."""
    predictions = model.predict(img_array)
    idx = np.argmax(predictions[0])
    confidence = predictions[0][idx]

    return class_names[idx], confidence, predictions[0]


def main():
    BASE_DIR = Path(__file__).parent

    img_path = input("Enter image path to classify: ").strip()
    img_path = Path(img_path)

    if not img_path.exists():
        print("Image path does not exist.")
        return

    model, class_names = load_model_and_classes(BASE_DIR)

    img_array = preprocess_image(img_path)
    label, conf, raw_probs = predict_image(model, class_names, img_array)

    print("\nPrediction Result")
    print(f"Predicted Class: {label}")
    print(f"Confidence: {conf * 100:.2f}%")
    print("\nClass probabilities:")
    for cls, prob in zip(class_names, raw_probs):
        print(f" - {cls}: {prob * 100:.2f}%")


if __name__ == "__main__":
    main()
