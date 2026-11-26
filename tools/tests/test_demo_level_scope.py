from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEVEL_PATH = ROOT / "data/levels/level-01-thu-vien.json"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def resource_path(value: str) -> Path:
    return ROOT / value.removeprefix("res://")


class DemoLevelScopeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.level = load_json(LEVEL_PATH)

    def test_demo_has_exactly_two_plant_cards_and_two_slots(self) -> None:
        self.assertEqual(self.level.get("seed_slots"), 2)
        self.assertEqual(
            self.level.get("available_plants"),
            ["truc-tien", "hong-lien-no"],
        )
        self.assertEqual(len(self.level["available_plants"]), 2)

    def test_both_demo_plant_sprites_exist(self) -> None:
        for plant_id in self.level["available_plants"]:
            data = load_json(ROOT / "data/plants" / f"{plant_id}.json")
            sprite = data.get("sprite", f"res://assets/plants/{plant_id}.png")
            self.assertTrue(
                resource_path(sprite).is_file(),
                f"Missing sprite for demo Plant {plant_id}: {sprite}",
            )

    def test_all_waves_use_exactly_two_zombie_types(self) -> None:
        zombie_ids = {
            zombie_id
            for wave in self.level["waves"]
            for zombie_id in wave.get("zombies", [])
        }
        self.assertEqual(zombie_ids, {"cuong-thi-thuong", "cuong-thi-non"})
        self.assertEqual(len(zombie_ids), 2)

    def test_both_demo_zombie_sprites_exist(self) -> None:
        zombie_ids = {
            zombie_id
            for wave in self.level["waves"]
            for zombie_id in wave.get("zombies", [])
        }
        for zombie_id in zombie_ids:
            data = load_json(ROOT / "data/zombies" / f"{zombie_id}.json")
            sprite = data.get("sprite", f"res://assets/zombies/{zombie_id}.png")
            self.assertTrue(
                resource_path(sprite).is_file(),
                f"Missing sprite for demo Zombie {zombie_id}: {sprite}",
            )

    def test_each_plant_has_a_defined_plant_food_effect(self) -> None:
        behavior_source = (ROOT / "behaviors/PlantBehavior.gd").read_text(encoding="utf-8")
        for plant_id in self.level["available_plants"]:
            data = load_json(ROOT / "data/plants" / f"{plant_id}.json")
            food = data.get("plant_food")
            self.assertIsNotNone(food, f"{plant_id} needs an explicit Plant Food effect")
            if isinstance(food, str):
                self.assertIn(f'"{food}"', behavior_source)


if __name__ == "__main__":
    unittest.main()
