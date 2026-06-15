from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any
from urllib.parse import urlparse

import requests

try:
    from bs4 import BeautifulSoup
except Exception:  # pragma: no cover - optional dependency
    BeautifulSoup = None


@dataclass
class ScrapeResult:
    raw_text: str
    title: str
    warnings: list[str]
    metadata: dict[str, Any]


class ScorecardScraper:
    def scrape(self, url: str) -> ScrapeResult:
        warnings: list[str] = []
        try:
            response = requests.get(url, timeout=20, headers={"User-Agent": "StatStrike/1.0"})
            response.raise_for_status()
        except Exception as exc:
            return ScrapeResult(raw_text="", title="", warnings=[f"Unable to fetch scorecard URL: {exc}"], metadata={"url": url})

        chunks: list[str] = []
        title = ""
        if BeautifulSoup is not None:
            soup = BeautifulSoup(response.text, "html.parser")
            for tag in soup(["script", "style", "noscript"]):
                tag.decompose()

            title = (soup.title.text if soup.title else "").strip()
            if title:
                chunks.append(title)

            for table in soup.find_all("table"):
                table_lines: list[str] = []
                for row in table.find_all("tr"):
                    cells = [cell.get_text(" ", strip=True) for cell in row.find_all(["th", "td"])]
                    if cells:
                        table_lines.append(" | ".join(cells))
                if table_lines:
                    chunks.append("\n".join(table_lines))

            text = soup.get_text("\n", strip=True)
            if text:
                chunks.append(text)
        else:
            raw_text = re.sub(r"\s+", " ", response.text)
            chunks.append(raw_text)
            title = urlparse(url).netloc
        raw_text = "\n\n".join(chunk for chunk in chunks if chunk).strip()

        if not raw_text:
            warnings.append(f"No readable scorecard content found at {url}")
        if not urlparse(url).scheme.startswith("http"):
            warnings.append("URL does not look like a public web link.")

        return ScrapeResult(
            raw_text=re.sub(r"\n{3,}", "\n\n", raw_text),
            title=title,
            warnings=warnings,
            metadata={"url": url},
        )


scorecard_scraper = ScorecardScraper()
