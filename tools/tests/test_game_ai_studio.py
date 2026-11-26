import json
import tempfile
import unittest
from pathlib import Path

from game_ai_studio import AgentRegistry, DataHub, GameOutputValidator, PromptBuilder


class GameAIStudioTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        for folder in ("data/plants", "data/zombies", "data/levels", "data/config"):
            (self.root / folder).mkdir(parents=True)
        (self.root / "data/config/game-settings.json").write_text("{}", encoding="utf-8")
        (self.root / "data/plants/p1.json").write_text(json.dumps({
            "name": "Plant", "cost": 50, "hp": 200, "type": "shooter"
        }), encoding="utf-8")
        (self.root / "data/zombies/z1.json").write_text(json.dumps({
            "name": "Zombie", "hp": 100, "speed": 10, "type": "basic"
        }), encoding="utf-8")
        (self.root / "data/levels/l1.json").write_text(json.dumps({
            "name": "Level", "available_plants": ["p1"],
            "waves": [{"zombies": ["z1"], "count": 3, "interval": 2}]
        }), encoding="utf-8")
        self.hub = DataHub(self.root)
        self.validator = GameOutputValidator(self.hub)

    def tearDown(self):
        self.temp.cleanup()

    def test_registry_routes_unique_capabilities(self):
        registry = AgentRegistry()
        self.assertEqual(registry.for_task("design_plant")["key"], "plant_designer")
        self.assertEqual(registry.for_task("review_output")["key"], "qa_reviewer")
        self.assertEqual(len(registry.list()), 12)

    def test_data_hub_returns_copies(self):
        value = self.hub.get("plants", "p1")
        value["hp"] = 1
        self.assertEqual(self.hub.get("plants", "p1")["hp"], 200)

    def test_valid_plant_schema(self):
        errors = self.validator.validate("plants", "new-plant", {
            "name": "New Plant", "cost": 75, "hp": 200, "type": "shooter"
        })
        self.assertEqual(errors, [])

    def test_unknown_ability_is_rejected(self):
        errors = self.validator.validate("plants", "new-plant", {
            "name": "New Plant", "cost": 75, "hp": 200, "type": "shooter",
            "abilities": {"invented_ability": True}
        })
        self.assertTrue(any("Unsupported Plant ability" in item for item in errors))

    def test_zombie_armor_break_speed_ability_is_supported(self):
        errors = self.validator.validate("zombies", "armored-runner", {
            "name": "Armored Runner", "hp": 200, "speed": 16, "type": "armored",
            "armor": {"hp": 100},
            "abilities": {"speed_after_armor_breaks": 32}
        })
        self.assertEqual(errors, [])

    def test_legacy_newspaper_speed_ability_remains_supported(self):
        errors = self.validator.validate("zombies", "legacy-newspaper", {
            "name": "Legacy Newspaper", "hp": 200, "speed": 16, "type": "newspaper",
            "armor": {"hp": 100},
            "abilities": {"speed_after_newspaper_breaks": 32}
        })
        self.assertEqual(errors, [])

    def test_growth_stages_must_be_ordered(self):
        errors = self.validator.validate("plants", "new-plant", {
            "name": "New Plant", "cost": 75, "hp": 200, "type": "producer",
            "abilities": {"growth_stages": [
                {"after_seconds": 20, "sun_amount": 30, "production_rate": 8},
                {"after_seconds": 10, "sun_amount": 40, "production_rate": 7}
            ]}
        })
        self.assertTrue(any("increasing" in item for item in errors))

    def test_level_references_are_checked(self):
        errors = self.validator.validate("levels", "new-level", {
            "name": "Level", "available_plants": ["missing"],
            "waves": [{"zombies": ["unknown"], "count": 1, "interval": 0.2}]
        })
        self.assertTrue(any("Unknown Plant ID" in item for item in errors))
        self.assertTrue(any("Unknown Zombie ID" in item for item in errors))

    def test_prompt_linter_has_no_invented_score(self):
        result = PromptBuilder.lint("Tạo Plant mới cho Godot, xuất JSON, không đổi ID.")
        self.assertIn("dimensions", result)
        self.assertNotIn("score", result)
        self.assertEqual(len(result["rewrite_sections"]), 11)

    def test_empty_prompt_is_not_gradeable(self):
        self.assertFalse(PromptBuilder.lint("")["enough_to_grade"])


if __name__ == "__main__":
    unittest.main()
