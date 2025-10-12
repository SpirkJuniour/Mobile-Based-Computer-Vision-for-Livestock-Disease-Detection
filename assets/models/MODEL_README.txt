MifugoCare - TensorFlow Lite Model

==================================================
IMPORTANT: MODEL FILE REQUIRED
==================================================

The file "livestock_disease_model.tflite" is REQUIRED for the app to function.

Place your trained TensorFlow Lite model in this folder:
assets/models/livestock_disease_model.tflite

MODEL SPECIFICATIONS:
- Input: [1, 224, 224, 3] (RGB image)
- Output: [1, 9] (9 disease classes)
- Format: TensorFlow Lite (.tflite)
- Expected Accuracy: > 95%

DISEASE CLASSES (in order):
1. East Coast Fever (ECF)
2. Lumpy Skin Disease
3. Foot and Mouth Disease (FMD)
4. Mastitis
5. Mange (Scabies)
6. Tick Infestation
7. Ringworm
8. CBPP (Contagious Bovine Pleuropneumonia)
9. Healthy - No Disease Detected

For testing without a model, create a dummy file:
- The app will run but predictions won't work
- You can still test UI and other features

Contact: support@mifugocare.com

