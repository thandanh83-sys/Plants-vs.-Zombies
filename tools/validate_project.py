#!/usr/bin/env python3
"""Validate the project's JSON data and local resource references (stdlib only)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []
WARNINGS: list[str] = []


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        ERRORS.append(f"{path.relative_to(ROOT)}: invalid JSON ({exc})")
        return None


def data_files(folder: str) -> dict[str, dict]:
    result = {}
    directory = ROOT / folder
    if not directory.is_dir():
        ERRORS.append(f"Missing directory: {folder}")
        return result
    for path in sorted(directory.glob("*.json")):
        value = load_json(path)
        if not isinstance(value, dict):
            ERRORS.append(f"{path.relative_to(ROOT)}: JSON root must be an object")
            continue
        result[path.stem] = value
    return result


plants = data_files("data/plants")
zombies = data_files("data/zombies")
levels = data_files("data/levels")
settings = load_json(ROOT / "data/config/game-settings.json")
ui_assets = load_json(ROOT / "data/config/ui-assets.json")

for plant_id, plant in plants.items():
    for field in ("name", "type", "hp", "cost"):
        if field not in plant:
            ERRORS.append(f"Plant {plant_id}: missing required field '{field}'")
    if float(plant.get("hp", 0)) <= 0 or int(plant.get("cost", -1)) < 0:
        ERRORS.append(f"Plant {plant_id}: hp/cost is invalid")
    behavior = plant.get("behavior_script")
    if behavior and not (ROOT / str(behavior).replace("res://", "")).is_file():
        ERRORS.append(f"Plant {plant_id}: behavior_script not found: {behavior}")
    sprite = plant.get("sprite", f"res://assets/plants/{plant_id}.png")
    if sprite and not (ROOT / str(sprite).replace("res://", "")).is_file():
        WARNINGS.append(f"Plant sprite not supplied yet: {sprite}")

for zombie_id, zombie in zombies.items():
    for field in ("name", "type", "hp", "speed"):
        if field not in zombie:
            ERRORS.append(f"Zombie {zombie_id}: missing required field '{field}'")
    if float(zombie.get("hp", 0)) <= 0 or float(zombie.get("speed", -1)) < 0:
        ERRORS.append(f"Zombie {zombie_id}: hp/speed is invalid")
    behavior = zombie.get("behavior_script")
    if behavior and not (ROOT / str(behavior).replace("res://", "")).is_file():
        ERRORS.append(f"Zombie {zombie_id}: behavior_script not found: {behavior}")
    sprite = zombie.get("sprite", f"res://assets/zombies/{zombie_id}.png")
    if sprite and not (ROOT / str(sprite).replace("res://", "")).is_file():
        WARNINGS.append(f"Zombie sprite not supplied yet: {sprite}")

for level_id, level in levels.items():
    if not isinstance(level.get("available_plants"), list):
        ERRORS.append(f"Level {level_id}: available_plants must be an array")
    if not isinstance(level.get("waves"), list):
        ERRORS.append(f"Level {level_id}: waves must be an array")
    for plant_id in level.get("available_plants", []):
        if plant_id not in plants:
            ERRORS.append(f"Level {level_id}: unknown plant '{plant_id}'")
    for wave_number, wave in enumerate(level.get("waves", []), start=1):
        if not isinstance(wave, dict):
            ERRORS.append(f"Level {level_id}: wave {wave_number} must be an object")
            continue
        for zombie_id in wave.get("zombies", []):
            if zombie_id not in zombies:
                ERRORS.append(f"Level {level_id}: wave {wave_number} references unknown zombie '{zombie_id}'")
    background = level.get("background", "")
    if background and not (ROOT / str(background).replace("res://", "")).is_file():
        WARNINGS.append(f"Background not supplied yet: {background}")

if not isinstance(settings, dict):
    ERRORS.append("game-settings.json must contain an object")
if not isinstance(ui_assets, dict):
    ERRORS.append("ui-assets.json must contain an object")

for warning in WARNINGS:
    print(f"WARNING: {warning}")
for error in ERRORS:
    print(f"ERROR: {error}")

print(f"Validated {len(plants)} plants, {len(zombies)} zombies and {len(levels)} levels.")
if ERRORS:
    sys.exit(1)
print("Data validation passed. Missing image/background files are warnings only.")
