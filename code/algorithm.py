from PIL import Image, ImageOps, ExifTags
from pillow_heif import register_heif_opener
import numpy as np
import os
import time

register_heif_opener()

class QuadTree:
    def __init__(self, image, threshold):
        self.image = image
        self.threshold = threshold
        self.width, self.height = image.size
        self.leaf_count = 0

    def compress(self):
        print(f"Starting compression with threshold: {self.threshold}")
        start_time = time.time()
        result = self._compress_recursive(0, 0, self.width, self.height)
        end_time = time.time()
        print(f"Compression completed in {end_time - start_time:.2f} seconds")
        print(f"Number of leaf nodes: {self.leaf_count}")
        return result
    
    def _compress_recursive(self, x, y, w, h):
        # Get region of interest
        region = self.image.crop((x, y, x + w, y + h))
        
        # Calculate mean color of the region
        mean_color = np.array(region).mean(axis=(0, 1))

        # Check if the region is homogeneous enough
        if self._is_homogeneous(region, mean_color) or w <= 1 or h <= 1:
            self.leaf_count += 1
            return [(x, y, w, h, tuple(mean_color.astype(int)))]
        
        # If not homogeneous, divide into quadrants
        w2, h2 = w // 2, h // 2
        return (self._compress_recursive(x, y, w2, h2) +
                self._compress_recursive(x + w2, y, w - w2, h2) +
                self._compress_recursive(x, y + h2, w2, h - h2) +
                self._compress_recursive(x + w2, y + h2, w - w2, h - h2))

    def _is_homogeneous(self, region, mean_color):
        # Calculate mean squared error
        mse = np.square(np.array(region) - mean_color).mean()
        return mse < self.threshold

def compress_image(input_path, output_path, threshold):
    print(f"\nProcessing image: {input_path}")
    print(f"Output path: {output_path}")
    print(f"Threshold: {threshold}")

    # Open the image
    with Image.open(input_path) as img:
        print(f"Original image size: {img.size}")
        
        # Ensure the image is in the correct orientation
        img = ImageOps.exif_transpose(img)
        
        # Convert to RGB mode if it's not already
        img = img.convert('RGB')
    
        # Perform quadtree compression
        quadtree = QuadTree(img, threshold)
        compressed_data = quadtree.compress()

        # Create a new image for the compressed result
        result = Image.new('RGB', img.size)
        pixels = result.load()  # Create a pixel map

        for x, y, w, h, color in compressed_data:
            for i in range(x, x + w):
                for j in range(y, y + h):
                    if 0 <= i < img.width and 0 <= j < img.height:
                        pixels[i, j] = color

        # Save compressed image
        result.save(output_path)
        
        # Print compression stats
        original_size = os.path.getsize(input_path)
        compressed_size = os.path.getsize(output_path)
        compression_ratio = (1 - compressed_size / original_size) * 100
        print(f"Original file size: {original_size} bytes")
        print(f"Compressed file size: {compressed_size} bytes")
        print(f"Compression ratio: {compression_ratio:.2f}%")

# Algorithm testing
if __name__ == "__main__":
    print("Starting Quadtree Image Compression")
    thresholds = [1400, 1600, 1800]
    main_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    input_file = 'EmmaBW-6.jpg' 
    input_path = os.path.join(main_dir, 'test', 'input', input_file)
    
    print(f"Input image: {input_path}")
    print(f"Thresholds to be tested: {thresholds}")
    
    # Get the file name without extension
    input_name = os.path.splitext(input_file)[0]
    
    for threshold in thresholds:
        output_file = f'{input_name}_compressed_t{threshold}.jpg'
        output_path = os.path.join(main_dir, 'test', 'output', output_file)
        compress_image(input_path, output_path, threshold)
    
    print("\nCompression process completed for all thresholds.")
