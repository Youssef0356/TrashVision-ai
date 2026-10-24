# TrashVision AI 🌍⚡

A gamified mobile application powered by on-device Computer Vision (YOLOv8 Nano & TensorFlow Lite).

Users capture photos of litter ("Before"), clean the physical area, and capture an "After" photo. TrashVision AI detects waste specimens, calculates a cleanliness score, and awards XP, ranks, and streak badges.

---

## 🛠️ Tech Stack & Architecture
- **Framework:** Flutter 3 (Android & iOS)
- **AI Model:** Custom YOLOv8 Nano trained on TACO (Trash Annotations in Context)
- **Inference Engine:** On-device TensorFlow Lite (`tflite_flutter`) — 100% offline, $0 server cost
- **Styling:** Bespoke Expedition Field Guide / Tactical Ranger HUD
  - Interactive "Curtain Wipe" Before/After Slider (`BeforeAfterSlider`)
  - Mechanical 3D Tactile Buttons (`TactileButton`)
  - Optical Rangefinder Reticles (`SurveyorReticlePainter`)
  - AI Verification Rubber Stamp (`RubberStamp`)

---

## 🚀 Getting Started

### 1. Run the App (Test / Simulator Mode)
The app runs right out of the box with a built-in sensor simulator:
```bash
flutter run
```

### 2. Plug in the Live Trained Neural Network
Once your Colab training completes:
1. Export the best model: `model.export(format='tflite')`
2. Place the resulting file at:
   ```
   assets/models/trash_detector.tflite
   ```
3. Run `flutter run` — TrashVision AI will automatically switch to live on-device neural network inference!
