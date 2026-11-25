# AI Content Studio - Van Gioi Linh Vien

A developer-side workbench inspired by the read-only Van Hien and Prompt repositories. Only Plants-vs.-Zombies receives code changes.

## Architecture

- **MasterAI and AgentRegistry:** route tasks to 12 specialists: game design, Plant, Zombie, Level, skills, balance, worldbuilding, asset prompts, QA, prompt architecture, and localization.
- **DataHub:** single read gateway for current Plant, Zombie, Level, and settings JSON. It caches by modification time and returns copies.
- **PromptBuilder:** separates untrusted briefs from system instructions, carries 14 prompt-quality dimensions and the fixed 11-section rewrite structure.
- **GameOutputValidator:** checks entity types, ability keys, numeric values, cross-references, growth-stage ordering, waves, and boss flags against current GDScript contracts.
- **QA Reviewer:** runs a separate model review after schema validation. Rejected results are not installed.
- **MemoryEngine:** keeps a bounded local record of task metadata and outcomes; it does not save API keys or full prompts.
- **Provider adapter:** uses an OpenAI-compatible chat-completions endpoint only when credentials are supplied through environment variables.

The tool uses the Python standard library and is not loaded by the Godot runtime. No AI key is embedded in game data, project settings, or HTML5 exports.

## Setup

Set these environment variables in your local terminal. Never commit them.

- **GAME_AI_API_KEY:** provider secret.
- **GAME_AI_MODEL:** model identifier.
- **GAME_AI_BASE_URL:** optional endpoint; defaults to the OpenAI API base URL.

The provider requires HTTPS. HTTP is allowed only for localhost.

## Commands

Run from the repository root:

~~~bash
python tools/game_ai_studio.py agents
python tools/game_ai_studio.py inspect --kind plants
python tools/game_ai_studio.py lint "Tạo Plant mới cho Godot, xuất JSON, không đổi ID"
python tools/game_ai_studio.py generate plants --id hoa-sen-moi --brief "Plant hỗ trợ phòng thủ hệ Thủy"
~~~

Generation writes a candidate to .game_ai/drafts/ by default. Review the JSON before installing. Only after reviewing, run with --install; an existing data file is protected unless --overwrite is explicitly supplied.

~~~bash
python tools/game_ai_studio.py generate plants --id hoa-sen-moi --brief "..." --install
~~~

The tool refuses unsupported abilities and arbitrary behavior-script paths. A new gameplay ability still requires a deliberate GDScript implementation and code review.

## Tests

~~~bash
python -m unittest discover -s tools/tests -v
~~~

Tests use fixture data and do not call an online model. Configure the provider only when intentionally generating content.

## Boundaries

- User briefs and retrieved repository data are input data, not system instructions.
- Do not paste secrets into prompts, JSON files, screenshots, logs, or commits.
- No AI request is made during normal gameplay.
- Drafts and memory are local, ignored by Git, and must be reviewed before entering data/.
- Sprite art and backgrounds remain separate assets; the tool can draft asset prompts but does not replace art files.
