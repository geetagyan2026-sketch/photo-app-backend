import io
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import Response
from PIL import Image
from rembg import remove
import uvicorn

app = FastAPI()

@app.get("/")
def home():
    return {"status": "AI Server is Running"}

@app.post("/blend")
async def blend_images(selfie: UploadFile = File(...), background: UploadFile = File(...)):
    try:
        # 1. Read the uploaded images
        selfie_bytes = await selfie.read()
        bg_bytes = await background.read()

        # 2. Open images with PIL
        input_image = Image.open(io.BytesIO(selfie_bytes)).convert("RGB")
        bg_image = Image.open(io.BytesIO(bg_bytes)).convert("RGB")

        # 3. AI Background Removal (The most intensive part)
        # This removes the background from the selfie
        subject_no_bg = remove(input_image) 

        # 4. Resize background and subject to match
        # We resize the subject to fit the background height
        bg_w, bg_h = bg_image.size
        # Simple scaling: make subject 80% of background height
        aspect_ratio = subject_no_bg.width / subject_no_bg.height
        new_h = int(bg_h * 0.8)
        new_w = int(new_h * aspect_ratio)
        subject_resized = subject_no_bg.resize((new_w, new_h), Image.LANCZOS)

        # 5. Composite (Place subject in the center-bottom)
        final_img = bg_image.copy()
        paste_x = (bg_w - new_w) // 2
        paste_y = bg_h - new_h
        final_img.paste(subject_resized, (paste_x, paste_y), subject_resized)

        # 6. Save result to bytes
        img_byte_arr = io.BytesIO()
        final_img.save(img_byte_arr, format='JPEG', quality=95)
        
        return Response(content=img_byte_arr.getvalue(), media_type="image/jpeg")

    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
