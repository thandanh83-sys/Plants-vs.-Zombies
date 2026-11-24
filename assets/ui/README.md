# Local asset relocation

Run this script after cloning the repository to move the three existing design images into the Godot asset folders:

```powershell
python tools/rename_assets.py
```

The script creates `assets/ui/` automatically and renames:

- `Biểu tượng hoa sen mực thủy mặc.png` → `assets/ui/logo.png`
- `Bùa Tre Trúc Ngọc Bích.png` → `assets/ui/seed-packet.png`
- `Quả cầu ngọc linh sen vàng.png` → `assets/ui/linh-khi.png`
