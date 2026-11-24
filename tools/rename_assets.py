from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "ui"
ASSETS.mkdir(parents=True, exist_ok=True)

MOVES = {
    "Biểu tượng hoa sen mực thủy mặc.png": "logo.png",
    "Bùa Tre Trúc Ngọc Bích.png": "seed-packet.png",
    "Quả cầu ngọc linh sen vàng.png": "linh-khi.png",
}

for source_name, target_name in MOVES.items():
    source = ROOT / source_name
    target = ASSETS / target_name
    if source.exists():
        if target.exists():
            print(f"Skip: {target.relative_to(ROOT)} already exists")
        else:
            source.rename(target)
            print(f"Moved: {source_name} -> {target.relative_to(ROOT)}")
    else:
        print(f"Not found: {source_name}")
