# Quadro: Quadtree Image Compression App

Quadro is an iOS application that demonstrates quadtree image compression using a Python backend. This project combines a SwiftUI frontend with a FastAPI backend to provide an interactive image compression experience.

## Project Overview

### Frontend (iOS App)
- Built with SwiftUI
- Features:
  - Example view showcasing before and after compression
  - Interactive compression tool
  - Learn More section explaining the quadtree algorithm

### Backend (Python)
- FastAPI server
- Implements quadtree compression algorithm

## How It Works

1. **Quadtree Compression Algorithm**
   The core of the project is the quadtree compression algorithm, which divides images into quadrants based on color homogeneity.

   ```python
   if __name__ == "__main__":
       print("Starting Quadtree Image Compression")
       thresholds = [1400, 1600, 1800]
       main_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
       input_file = "EmmaBW-6.jpg"
       input_path = os.path.join(main_dir, "test", "input", input_file)
       print(f"Input image: {input_path}")
       print(f"Thresholds to be tested: {thresholds}")
       
       # Get the file name without extension
       input_name = os.path.splitext(input_file)[0]
       
       for threshold in thresholds:
           output_file = f"{input_name}_compressed_t{threshold}.jpg"
           output_path = os.path.join(main_dir, "test", "output", output_file)
           compress_image(input_path, output_path, threshold)
       
       print("\nCompression process completed for all thresholds.")
   ```

   This script demonstrates how the backend processes images with different compression thresholds, allowing for flexible and customizable image compression.



2. **iOS App Interface**
   The app provides an intuitive interface for users to interact with the compression algorithm.

3. **Server Communication**
   The app communicates with the Python backend to perform image compression.

## Getting Started

1. Clone the repository
2. Set up the Python backend (instructions in backend folder)
3. Open the Xcode project and run the iOS app
