import cv2
import numpy as np
import requests
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
from rembg import remove
import io

app = FastAPI()

@app.post("/blend")
async def remove_background_and_blend(user_file: UploadFile = File(...), bg_url: str = "https://unsplash.com"):
    # 1. यूजर की फोटो को रीड करें
    user_data = await user_file.read()
    
    # 2. एआई से बैकग्राउंड हटाएं (सफेद बॉक्स का खात्मा)
    output_data = remove(user_data)
    nparr = np.frombuffer(output_data, np.uint8)
    user_png = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
    
    # 3. ताजमहल की बैकग्राउंड फोटो डाउनलोड करें
    response = requests.get(bg_url)
    bg_bytes = np.frombuffer(response.content, np.uint8)
    bg_img = cv2.imdecode(bg_bytes, cv2.IMREAD_COLOR)
    
    h_bg, w_bg, _ = bg_img.shape
    
    # 4. साइज को परफेक्ट करें (1.4 गुना बड़ा ताकि फोटो असली लगे)
    scale_factor = (h_bg * 0.55) / user_png.shape[0]
    user_resized = cv2.resize(user_png, (0,0), fx=scale_factor, fy=scale_factor)
    h_u, w_u, _ = user_resized.shape
    
    # 5. पोजीशन फिक्स (लड़की को स्क्रीन के नीचे कटने से बचाकर सीधे ताजमहल के रास्ते पर खड़ा करना)
    y_offset = int(h_bg * 0.52) # इसे 0.52 किया ताकि लड़की सीधे मुख्य वॉकवे (जमीन) पर दिखे
    x_offset = (w_bg - w_u) // 2
    
    # सीमा जांच (Boundary Check)
    if y_offset + h_u > h_bg:
        y_offset = h_bg - h_u
        
    # 6. ओवरले और धूप की लाइटिंग को मैच करना
    alpha_mask = user_resized[:, :, 3] / 255.0
    user_rgb = user_resized[:, :, 0:3]
    user_rgb = cv2.convertScaleAbs(user_rgb, alpha=1.05, beta=5) # हल्का वार्म टोन
    
    for c in range(0, 3):
        bg_img[y_offset:y_offset+h_u, x_offset:x_offset+w_u, c] = (
            alpha_mask * user_rgb[:, :, c] + 
            (1.0 - alpha_mask) * bg_img[y_offset:y_offset+h_u, x_offset:x_offset+w_u, c]
        )
        
    # 7. पैरों के नीचे हलकी परछाईं का इफ़ेक्ट (Shadow Drop)
    shadow_mask = cv2.GaussianBlur((alpha_mask * 255).astype(np.uint8), (21, 21), 0)
    
    # फाइनल सेव और रिस्पॉन्स
    output_path = "final_output.jpg"
    cv2.imwrite(output_path, bg_img)
    return FileResponse(output_path, media_type="image/jpeg")
