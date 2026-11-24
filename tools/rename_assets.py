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
failed = False
for source_name, target_name in MOVES.items():
    source = ROOT / source_name
    target = TARGET_DIR / target_name
    if target.exists():
        print(f"Đã có, giữ nguyên cả hai file: {target.relative_to(ROOT)}")
    elif not source.is_file():
        print(f"Không tìm thấy ảnh nguồn: {source_name}")
        failed = True
    else:
        shutil.move(str(source), str(target))
        print(f"Đã đổi tên: {source_name} -> {target.relative_to(ROOT)}")

if failed:
    raise SystemExit("Một số ảnh nguồn không tìm thấy. Kiểm tra tên file trong thư mục gốc repo.")
