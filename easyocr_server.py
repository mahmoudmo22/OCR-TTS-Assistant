from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import easyocr
import numpy as np
from PIL import Image
import io

app = FastAPI()
reader = easyocr.Reader(["ar", "en"], gpu=False)


@app.post("/ocr")
async def ocr(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)

    results = reader.readtext(image_np, detail=1)

    def sort_key(item):
        bbox = item[0]
        y_center = sum([p[1] for p in bbox]) / 4.0
        x_center = sum([p[0] for p in bbox]) / 4.0
        return (y_center, x_center)

    results.sort(key=sort_key)
    lines = [r[1] for r in results]
    text = "\n".join(lines)

    return JSONResponse({"text": text})
