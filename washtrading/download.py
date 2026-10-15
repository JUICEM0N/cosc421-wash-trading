import hashlib
from pathlib import Path

import requests
from tqdm import tqdm

from .config import RAW_DIR, RAW_FILES, ZENODO_FILES_URL


def md5sum(path: Path) -> str:
    digest = hashlib.md5()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def download_file(name: str, expected_md5: str) -> Path:
    target = RAW_DIR / name
    if target.exists() and md5sum(target) == expected_md5:
        return target

    url = f"{ZENODO_FILES_URL}/{name}?download=1"
    with requests.get(url, stream=True, timeout=60) as response:
        response.raise_for_status()
        total = int(response.headers.get("content-length", 0))
        with open(target, "wb") as handle, tqdm(total=total, unit="B", unit_scale=True, desc=name) as bar:
            for chunk in response.iter_content(chunk_size=1 << 20):
                handle.write(chunk)
                bar.update(len(chunk))

    if md5sum(target) != expected_md5:
        raise ValueError(f"Checksum mismatch for {name}, delete it and download again")
    return target


def download_all() -> list[Path]:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    return [download_file(name, checksum) for name, checksum in RAW_FILES.items()]
