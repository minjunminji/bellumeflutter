# TensorFlow Lite Models

This directory contains TensorFlow Lite models for facial analysis.

## Required Models

### Face Mesh Model (`face_mesh.tflite`)
- **Purpose**: Detects 468 3D facial landmarks
- **Input**: 192x192x3 RGB image
- **Output**: 468 landmark coordinates (x, y, z)
- **Download**: Get from MediaPipe or TensorFlow Hub
- **URL**: https://tfhub.dev/mediapipe/face_mesh/1

## Setup Instructions

1. Download the `face_mesh.tflite` model from TensorFlow Hub
2. Place it in this `models/` directory
3. Ensure the file is named exactly `face_mesh.tflite`
4. The app will automatically load and use the model for facial landmark detection

## Development Mode

Currently, the app runs in simulation mode without the actual model file. This allows development and testing of the camera interface and facial pose detection logic without requiring the large model file.

To enable real facial landmark detection:
1. Add the `face_mesh.tflite` file to this directory
2. The `FacialLandmarkService` will automatically detect and use the model

## Model Performance

- **Accuracy**: ~95% for well-lit frontal faces
- **Speed**: ~30-60 FPS on modern devices
- **Size**: ~2.6 MB
- **Platform**: Works on Android, iOS, and Web 