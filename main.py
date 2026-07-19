import cv2
import numpy as np
import requests
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
from rembg import remove

app = FastAPI()

@app.post("/blend")
async def remove_background_and_blend(user_file: UploadFile = File(...), bg_url: str = "https://unsplash.com"):
    user_data = await user_file.read()
    
    # 1. AI से बैकग्राउंड रिमूवल (पारदर्शी PNG बनाना)
    output_data = remove(user_data)
    nparr = np.frombuffer(output_data, np.uint8)
    user_png = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
    
    # 2. ताजमहल बैकग्राउंड डाउनलोड और लोड
    response = requests.get(bg_url)
    bg_bytes = np.frombuffer(response.content, np.uint8)
    bg_img = cv2.imdecode(bg_bytes, cv2.IMREAD_COLOR)
    
    h_bg, w_bg, _ = bg_img.shape
    
    # 3. परफेक्ट स्केल (साइज़ थोड़ा बड़ा ताकि यूजर ओरिजिनल लगे)
    scale_factor = (h_bg * 0.48) / user_png.shape[0]
    user_resized = cv2.resize(user_png, (0,0), fx=scale_factor, fy=scale_factor)
    h_u, w_u, _ = user_resized.shape
    
    # 4. पोजीशन फिक्स: लड़की को 40% ऊपर शिफ्ट किया ताकि वह सीधे मुख्य रास्ते पर आए
    y_offset = int(h_bg * 0.42) 
    x_offset = (w_bg - w_u) // 2
    
    if y_offset + h_u > h_bg:
        y_offset = h_bg - h_u
        
    # 5. अल्फा ब्लेंडिंग और साफ्ट वार्म टोन मैचिंग
    alpha_mask = user_resized[:, :, 3] / 255.0
    user_rgb = user_resized[:, :, 0:3]
    user_rgb = cv2.convertScaleAbs(user_rgb, alpha=1.02, beta=5)
    
    for c in range(0, 3):
        bg_img[y_offset:y_offset+h_u, x_offset:x_offset+w_u, c] = (
            alpha_mask * user_rgb[:, :, c] + 
            (1.0 - alpha_mask) * bg_img[y_offset:y_offset+h_u, x_offset:x_offset+w_u, c]
        )
        
    output_path = "final_output.jpg"
    cv2.imwrite(output_path, bg_img)
    return FileResponse(output_path, media_type="image/jpeg")
