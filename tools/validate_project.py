#!/usr/bin/env python3
"""Validate game JSON, cross-references, and resource paths (stdlib only)."""
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
    result: dict[str, dict] = {}
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
    if not result:
        ERRORS.append(f"No JSON data files found in {folder}")
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
    try:
        if float(plant.get("hp", 0)) <= 0 or int(plant.get("cost", -1)) < 0:
            ERRORS.append(f"Plant {plant_id}: hp/cost is invalid")
    except (TypeError, ValueError):
        ERRORS.append(f"Plant {plant_id}: hp/cost must be numeric")
    if "recharge_time" in plant:
        try:
            if float(plant["recharge_time"]) < 0:
                ERRORS.append(f"Plant {plant_id}: recharge_time cannot be negative")
        except (TypeError, ValueError):
            ERRORS.append(f"Plant {plant_id}: recharge_time must be numeric")
    abilities = plant.get("abilities", {})
    if not isinstance(abilities, dict):
        ERRORS.append(f"Plant {plant_id}: abilities must be an object")
        abilities = {}
    stages = abilities.get("growth_stages", [])
    if not isinstance(stages, list):
        ERRORS.append(f"Plant {plant_id}: growth_stages must be an array")
    else:
        previous_time = -1.0
        for index, stage in enumerate(stages, start=1):
            if not isinstance(stage, dict):
                ERRORS.append(f"Plant {plant_id}: growth stage {index} must be an object")
                continue
            try:
                after = float(stage["after_seconds"])
                amount = int(stage["sun_amount"])
                rate = float(stage["production_rate"])
                if after < 0 or after <= previous_time:
                    ERRORS.append(f"Plant {plant_id}: growth stage times must be increasing")
                if amount < 0 or rate <= 0:
                    ERRORS.append(f"Plant {plant_id}: growth stage production values are invalid")
                previous_time = after
            except (KeyError, TypeError, ValueError):
                ERRORS.append(f"Plant {plant_id}: growth stage {index} has missing or invalid fields")
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
    try:
        if float(zombie.get("hp", 0)) <= 0 or float(zombie.get("speed", -1)) < 0:
            ERRORS.append(f"Zombie {zombie_id}: hp/speed is invalid")
    except (TypeError, ValueError):
        ERRORS.append(f"Zombie {zombie_id}: hp/speed must be numeric")
    armor = zombie.get("armor", {})
    if not isinstance(armor, dict):
        ERRORS.append(f"Zombie {zombie_id}: armor must be an object")
    elif "hp" in armor:
        try:
            if float(armor["hp"]) < 0:
                ERRORS.append(f"Zombie {zombie_id}: armor hp cannot be negative")
        except (TypeError, ValueError):
            ERRORS.append(f"Zombie {zombie_id}: armor hp must be numeric")
    behavior = zombie.get("behavior_script")
    if behavior and not (ROOT / str(behavior).replace("res://", "")).is_file():
        ERRORS.append(f"Zombie {zombie_id}: behavior_script not found: {behavior}")
    sprite = zombie.get("sprite", f"res://assets/zombies/{zombie_id}.png")
    if sprite and not (ROOT / str(sprite).replace("res://", "")).is_file():
        WARNINGS.append(f"Zombie sprite not supplied yet: {sprite}")

for level_id, level in levels.items():
    available_plants = level.get("available_plants", [])
    if not isinstance(available_plants, list):
        ERRORS.append(f"Level {level_id}: available_plants must be an array")
        available_plants = []
    if len(available_plants) != len(set(available_plants)):
        ERRORS.append(f"Level {level_id}: available_plants contains duplicate IDs")
    for plant_id in available_plants:
        if plant_id not in plants:
            ERRORS.append(f"Level {level_id}: unknown plant '{plant_id}'")

    required_plants = level.get("required_plants", [])
    if not isinstance(required_plants, list):
        ERRORS.append(f"Level {level_id}: required_plants must be an array")
        required_plants = []
    if len(required_plants) != len(set(required_plants)):
        ERRORS.append(f"Level {level_id}: required_plants contains duplicate IDs")
    for plant_id in required_plants:
        if plant_id not in available_plants:
            ERRORS.append(f"Level {level_id}: required Plant '{plant_id}' is not in available_plants")
        elif plant_id not in plants:
            ERRORS.append(f"Level {level_id}: unknown required Plant '{plant_id}'")

    if isinstance(settings, dict):
        try:
            slots = int(settings.get("seed_slots", 6))
            if len(required_plants) > slots:
                ERRORS.append(f"Level {level_id}: required_plants exceeds configured seed_slots")
        except (TypeError, ValueError):
            pass

    if not isinstance(level.get("waves"), list):
        ERRORS.append(f"Level {level_id}: waves must be an array")
    wave_list = level.get("waves", [])
    has_boss_wave = False
    for wave_number, wave in enumerate(wave_list, start=1):
        if not isinstance(wave, dict):
            ERRORS.append(f"Level {level_id}: wave {wave_number} must be an object")
            continue
        has_boss_wave = has_boss_wave or bool(wave.get("boss", False))
        zombie_ids = wave.get("zombies", [])
        if not isinstance(zombie_ids, list) or not zombie_ids:
            ERRORS.append(f"Level {level_id}: wave {wave_number} must have zombie IDs")
        else:
            for zombie_id in zombie_ids:
                if zombie_id not in zombies:
                    ERRORS.append(f"Level {level_id}: wave {wave_number} references unknown zombie '{zombie_id}'")
        try:
            if int(wave.get("count", 1)) < 0 or float(wave.get("interval", 2.5)) <= 0:
                ERRORS.append(f"Level {level_id}: wave {wave_number} has invalid count/interval")
        except (TypeError, ValueError):
            ERRORS.append(f"Level {level_id}: wave {wave_number} count/interval must be numeric")
    mechanics = level.get("special_mechanics", [])
    if not isinstance(mechanics, list):
        ERRORS.append(f"Level {level_id}: special_mechanics must be an array")
        mechanics = []
    if "boss_wave" in mechanics and not has_boss_wave:
        ERRORS.append(f"Level {level_id}: boss_wave is set but no wave has boss=true")
    water_lanes = level.get("water_lanes", [])
    if not isinstance(water_lanes, list):
        ERRORS.append(f"Level {level_id}: water_lanes must be an array")
    else:
        for lane in water_lanes:
            if not isinstance(lane, int) or lane < 0 or lane >= 5:
                ERRORS.append(f"Level {level_id}: water lane index is outside the configured 5-row grid")
    background = level.get("background", "")
    if background and not (ROOT / str(background).replace("res://", "")).is_file():
        WARNINGS.append(f"Background not supplied yet: {background}")

if not isinstance(settings, dict):
    ERRORS.append("game-settings.json must contain an object")
else:
    try:
        seed_slots = int(settings.get("seed_slots", 6))
        if seed_slots < 1 or seed_slots > 10:
            ERRORS.append("game-settings.json: seed_slots must be between 1 and 10")
    except (TypeError, ValueError):
        ERRORS.append("game-settings.json: seed_slots must be an integer")
if not isinstance(ui_assets, dict):
    ERRORS.append("ui-assets.json must contain an object")

for warning in WARNINGS:
    print(f"WARNING: {warning}")
for error in ERRORS:
    print(f"ERROR: {error}")

print(f"Validated {len(plants)} plants, {len(zombies)} zombies and {len(levels)} levels.")
if ERRORS:
    sys.exit(1)
print("Data validation passed. Missing Plant/Zombie/background images are warnings only.")
