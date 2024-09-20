from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import FileResponse
import shutil
import os
from PIL import Image
import io
from algorithm import compress_image  # Import your existing compression function

app = FastAPI()

@app.post("/compress/")
async def compress(file: UploadFile = File(...), threshold: int = Form(...)):
    # Save the uploaded file temporarily
    with open("temp_image.jpg", "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Compress the image
    compress_image("temp_image.jpg", "compressed_image.jpg", threshold)
    
    # Return the compressed image
    return FileResponse("compressed_image.jpg", media_type="image/jpeg", filename="compressed_image.jpg")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        reload_dirs=['/Users/josemaldonado/Development/projects/art/quadtree/code']
    )