from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
TARGET_DIR = ROOT / "assets" / "ui"
MOVES = {
    "Biểu tượng hoa sen mực thủy mặc.png": "logo.png",
    "Bùa Tre Trúc Ngọc Bích.png": "seed-packet.png",
    "Quả cầu ngọc linh sen vàng.png": "linh-khi.png",
}

TARGET_DIR.mkdir(parents=True, exist_ok=True)
missing = []
for source_name, target_name in MOVES.items():
    source = ROOT / source_name
    target = TARGET_DIR / target_name
    if target.is_file():
        print(f"Đã có: {target.relative_to(ROOT)}")
    elif source.is_file():
        shutil.move(str(source), str(target))
        print(f"Đã chuyển: {source_name} -> {target.relative_to(ROOT)}")
    else:
        print(f"Không tìm thấy ảnh nguồn hoặc ảnh đích: {source_name}")
        missing.append(source_name)

if missing:
    raise SystemExit("Hãy tải/copy ảnh thiếu vào thư mục gốc repo rồi chạy lại script.")
