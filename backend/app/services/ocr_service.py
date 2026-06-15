from __future__ import annotations

from dataclasses import dataclass
from io import BytesIO
from typing import Any, Optional

from PIL import Image, ImageOps, ImageFilter

try:  # Optional acceleration / OCR support
    import cv2  # type: ignore
    import numpy as np  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    cv2 = None
    np = None

try:  # Optional OCR engines
    import easyocr  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    easyocr = None

try:  # Optional OCR engines
    from paddleocr import PaddleOCR  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    PaddleOCR = None

try:
    import pytesseract  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    pytesseract = None

try:
    import fitz  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    fitz = None


@dataclass
class OCRResult:
    text: str
    confidence: float
    warnings: list[str]


class OCRService:
    def __init__(self):
        self._easyocr_reader = None
        self._paddleocr = None

    def _load_image(self, content: bytes) -> Image.Image:
        return Image.open(BytesIO(content)).convert("RGB")

    def _preprocess_image(self, image: Image.Image) -> Image.Image:
        working = ImageOps.grayscale(image)
        working = ImageOps.autocontrast(working)
        working = working.filter(ImageFilter.MedianFilter(size=3))
        if cv2 is not None and np is not None:
            array = np.array(working)
            array = cv2.resize(array, None, fx=1.5, fy=1.5, interpolation=cv2.INTER_CUBIC)
            array = cv2.GaussianBlur(array, (3, 3), 0)
            array = cv2.adaptiveThreshold(
                array,
                255,
                cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                cv2.THRESH_BINARY,
                31,
                11,
            )
            return Image.fromarray(array)
        return working

    def _easyocr_extract(self, image: Image.Image) -> Optional[OCRResult]:
        if easyocr is None:
            return None
        try:
            if self._easyocr_reader is None:
                self._easyocr_reader = easyocr.Reader(["en"], gpu=False)
            image_array = np.array(image) if np is not None else image
            result = self._easyocr_reader.readtext(image_array, detail=1)
            texts = [item[1] for item in result if len(item) >= 2]
            confidences = [float(item[2]) for item in result if len(item) >= 3]
            text = "\n".join(texts).strip()
            confidence = round(sum(confidences) / len(confidences), 3) if confidences else 0.0
            return OCRResult(text=text, confidence=confidence, warnings=[])
        except Exception:
            return None

    def _paddleocr_extract(self, image: Image.Image) -> Optional[OCRResult]:
        if PaddleOCR is None:
            return None
        try:
            if self._paddleocr is None:
                self._paddleocr = PaddleOCR(use_angle_cls=True, lang="en", show_log=False)
            image_array = np.array(image) if np is not None else image
            result = self._paddleocr.ocr(image_array, cls=True)
            texts: list[str] = []
            confidences: list[float] = []
            for page in result or []:
                for line in page or []:
                    texts.append(line[1][0])
                    confidences.append(float(line[1][1]))
            text = "\n".join(texts).strip()
            confidence = round(sum(confidences) / len(confidences), 3) if confidences else 0.0
            return OCRResult(text=text, confidence=confidence, warnings=[])
        except Exception:
            return None

    def _tesseract_extract(self, image: Image.Image) -> OCRResult:
        warnings: list[str] = []
        if pytesseract is None:
            return OCRResult(text="", confidence=0.0, warnings=["No OCR engine is installed."])
        try:
            data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
            words: list[str] = []
            confidences: list[float] = []
            for text, confidence in zip(data.get("text", []), data.get("conf", []), strict=False):
                cleaned = (text or "").strip()
                if cleaned:
                    words.append(cleaned)
                try:
                    confidence_value = float(confidence)
                    if confidence_value >= 0:
                        confidences.append(confidence_value / 100.0)
                except Exception:
                    continue
            if not words:
                plain_text = pytesseract.image_to_string(image)
                text = plain_text.strip()
            else:
                text = "\n".join(words).strip()
            confidence = round(sum(confidences) / len(confidences), 3) if confidences else 0.35 if text else 0.0
            return OCRResult(text=text, confidence=confidence, warnings=warnings)
        except Exception as exc:
            return OCRResult(text="", confidence=0.0, warnings=[f"Tesseract OCR failed: {exc}"])

    def extract_text_from_image_bytes(self, content: bytes, filename: Optional[str] = None) -> OCRResult:
        image = self._preprocess_image(self._load_image(content))
        for extractor in (self._easyocr_extract, self._paddleocr_extract):
            result = extractor(image)
            if result and result.text.strip():
                return result
        result = self._tesseract_extract(image)
        if not result.text.strip():
            result.warnings.append(f"No readable text extracted from {filename or 'image'}.")
        return result

    def extract_text_from_pdf_bytes(self, content: bytes, filename: Optional[str] = None) -> OCRResult:
        if fitz is None:
            return OCRResult(text="", confidence=0.0, warnings=["PyMuPDF is not installed for PDF extraction."])
        warnings: list[str] = []
        text_parts: list[str] = []
        confidence_scores: list[float] = []
        try:
            document = fitz.open(stream=content, filetype="pdf")
            for page_index, page in enumerate(document):
                page_text = page.get_text("text").strip()
                if page_text:
                    text_parts.append(page_text)
                    confidence_scores.append(0.8)
                    continue
                pixmap = page.get_pixmap(matrix=fitz.Matrix(2, 2), alpha=False)
                image = Image.frombytes("RGB", [pixmap.width, pixmap.height], pixmap.samples)
                image_result = self.extract_text_from_image_bytes(_image_to_bytes(image), filename=f"{filename or 'pdf'}:{page_index + 1}")
                if image_result.text.strip():
                    text_parts.append(image_result.text)
                confidence_scores.append(image_result.confidence)
                warnings.extend(image_result.warnings)
            text = "\n".join(part for part in text_parts if part).strip()
            confidence = round(sum(confidence_scores) / len(confidence_scores), 3) if confidence_scores else 0.0
            if not text:
                warnings.append(f"No text found in PDF {filename or ''}".strip())
            return OCRResult(text=text, confidence=confidence, warnings=warnings)
        except Exception as exc:
            return OCRResult(text="", confidence=0.0, warnings=[f"PDF OCR failed: {exc}"])


def _image_to_bytes(image: Image.Image) -> bytes:
    buffer = BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue()


ocr_service = OCRService()
