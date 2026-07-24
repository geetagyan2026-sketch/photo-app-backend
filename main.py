import os
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import StreamingResponse
from io import BytesIO
from PIL import Image, ImageEnhance
from rembg import remove
import requests

app = FastAPI()

# Render पर मेमोरी लिमिट क्रैश से बचने के लिए
os.environ["OMP_NUM_THREADS"] = "1"

@app.get("/")
def home():
    return {"status": "AI Travel Backend is Running Successfully!"}

@app.post("/blend")
async def blend_images(image: UploadFile = File(...), location: str = Form(...)):
    try:
        # 1. यूजर की फोटो रीड करना
        user_bytes = await image.read()
        
        # 2. बैकग्राउंड रिमूव करना
        subject_img_data = remove(user_bytes)
        subject_img = Image.open(BytesIO(subject_img_data)).convert("RGBA")

        # 3. अनस्प्लैश से लोकेशन इमेज लाना
        unsplash_url = f"https://unsplash.com"
        if location:
            unsplash_url = f"https://unsplash.com?{location}"
            
        bg_response = requests.get(unsplash_url, timeout=15)
        bg_img = Image.open(BytesIO(bg_response.content)).convert("RGBA")

        # 4. यूजर इमेज को रीसाइज और पोजीशन करना
        aspect_ratio = subject_img.width / subject_img.height
        new_height = int(bg_img.height * 0.65)
        new_width = int(new_height * aspect_ratio)
        subject_img = subject_img.resize((new_width, new_height), Image.Resampling.LANCZOS)

        # राइट कॉर्नर में नीचे सेट करना
        position = (bg_img.width - subject_img.width - 50, bg_img.height - subject_img.height)

        # 5. ओरिजिनल इफ़ेक्ट के लिए हल्की लाइटिंग सेट करना
        enhancer = ImageEnhance.Brightness(subject_img)
        subject_img = enhancer.enhance(0.95)

        # कंपोजिट इमेज बनाना
        final_img = Image.new("RGBA", bg_img.size)
        final_img.paste(bg_img, (0, 0))
        final_img.paste(subject_img, position, mask=subject_img)

        # 6. इमेज वापस भेजना
        img_io = BytesIO()
        final_img.convert("RGB").save(img_io, 'JPEG', quality=95)
        img_io.seek(0)
        
        return StreamingResponse(img_io, media_type="image/jpeg")

    except Exception as e:
        return {"error": str(e)}
