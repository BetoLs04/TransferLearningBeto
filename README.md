# Beverage Image Classifier (MobileNetV2 - Transfer Learning)

This project implements a beverage classifier using **transfer learning** with **MobileNetV2**.  
The model is trained to classify three drink categories:

- Cola  
- Orange Juice  
- Water  

The repository is fully plug-and-play, uses relative paths, follows clean code practices, and respects the required project structure.

@author: Lazaro Roberto Luevano Serna
@date: 2025-12-04
@version: 1.0

---

## Project Structure

TRANSFER LEARNING/
│
├── src/
│ ├── train.py
│ └── predict.py
│
├── dataset/
│ ├── train/
│ │ ├── cola/
│ │ ├── orange_juice/
│ │ └── water/
│ └── val/
│ ├── cola/
│ ├── orange_juice/
│ └── water/
│
├── models/
│ └── beverage_classifier.h5
│
└── README.md


### Dataset Requirements
- Training and validation images **must be different**.
- Each class must have its own folder inside `train/` and `val/`.
- Recommended:
  - **10+ images per class** for training  
  - **3–5 images per class** for validation  

---

## How to Train the Model

Run: python3 src/train.py or train.py in src


This script:
- Loads the dataset  
- Uses MobileNetV2 (ImageNet weights)  
- Trains a simple classifier  
- Saves the model to `models/beverage_classifier.h5`  

---

## How to Make Predictions

Run: python3 src/predict.py or predict.py in src

You will be asked to enter the path to an image, and the script will output the predicted class:

- `cola`  
- `orange_juice`  
- `water` 



