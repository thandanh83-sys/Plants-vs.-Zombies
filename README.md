# Vạn Giới Linh Viên

Godot 4 tower-defense prototype inspired by Plants vs. Zombies and Vietnamese culture.

## Development

Open `project.godot` in Godot 4.2 or newer and run `res://scenes/Main.tscn`.

## Asset organization

Runtime assets should live under:

- `assets/ui/` — logo, seed packet and currency images
- `assets/plants/` — plant sprites
- `assets/zombies/` — zombie sprites
- `assets/backgrounds/` — level backgrounds

To relocate the three currently uploaded UI source images, run:

```powershell
python tools/rename_assets.py
```

## Data-driven content

- Plant definitions: `data/plants/*.json`
- Zombie definitions: `data/zombies/*.json`
- Level definitions: `data/levels/*.json`
- Shared settings: `data/config/game-settings.json`
