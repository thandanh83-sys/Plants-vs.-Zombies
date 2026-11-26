# Development Toolchain & File Formats

## 1. Nguyên tắc kiến trúc

Dự án **không bị giới hạn ở một ngôn ngữ hoặc một phần mềm**. Có thể phối hợp engine, công cụ đồ họa, âm thanh, biên tập dữ liệu, AI và tự động hóa.

Tuy nhiên phải phân biệt ba khái niệm:

1. **Runtime/engine:** phần trực tiếp chạy game. Hiện repository này dùng Godot 4.2+.
2. **Authoring tools:** phần mềm tạo nội dung hoặc prototype, ví dụ Blender, Aseprite, Krita, Photoshop, Audacity, DAW hoặc Unity Editor.
3. **Build/QA tools:** Python, GitHub Actions, validator, test runner và công cụ export.

Một file C# của Unity không thể được chạy trực tiếp bởi Godot. Tương tự, GDScript không chạy trong Unity. Muốn dùng Unity làm runtime thứ hai phải thêm Unity project độc lập, định nghĩa cách chia sẻ dữ liệu/asset và thiết lập build/test riêng. Không tạo thư mục Unity rỗng chỉ để tuyên bố đã tích hợp.

## 2. Công cụ đang có trong repository

| Công cụ/hệ thống | Vai trò thực tế | Dấu vết trong repo |
|---|---|---|
| Godot 4.2+ | Runtime game hiện tại, scene, gameplay, export Web | `project.godot`, `scenes/`, `core/`, `behaviors/`, `export_presets.cfg` |
| GDScript | Logic runtime Godot | `*.gd` |
| Python 3 | Validator, AI Content Studio, unit tests và hỗ trợ asset | `tools/*.py`, `tools/tests/` |
| JSON | Dữ liệu Plant, Zombie, level, cấu hình | `data/**/*.json` |
| Git/GitHub Actions | Quản lý mã, kiểm tra tự động, export artifact Web | `.github/workflows/validate-and-export-web.yml` |
| HTML/CSS/JavaScript | HTML shell và phần tích hợp trình duyệt cho Web export | `web/custom_shell.html` |
| PNG | Texture/UI/art raster mà runtime hiện đọc | `assets/**/*.png` |
| OGG | Định dạng âm thanh runtime ưu tiên | `assets/audio/README.md` |

CI hiện chỉ thiết lập và xác minh Python + Godot 4.2.2. Nó không cài Unity, không build Unity và không kiểm tra project Blender/Aseprite bên ngoài.

## 3. Công cụ có thể phối hợp (chưa mặc định là dependency)

| Công cụ | Dùng vào việc gì | Định dạng trao đổi phù hợp | Trạng thái |
|---|---|---|---|
| Unity Editor | Prototype gameplay/UX riêng, dựng công cụ Editor hoặc thử nghiệm nhánh Unity độc lập | `.unity`, `.prefab`, `.asset`, `.cs`, PNG, WAV/OGG, JSON | Chưa có Unity project trong repo |
| Blender | Model 3D, render concept, tạo sprite sheet/animation hoặc asset 3D | `.blend` nguồn; PNG/WebP render; GLB/GLTF khi dùng 3D | Chưa có file Blender trong repo |
| Aseprite | Pixel art, sprite sheet, animation 2D | `.aseprite` nguồn; PNG sprite sheet/frame | Chưa có file Aseprite trong repo |
| Krita/Photoshop/GIMP | Vẽ concept, texture, UI và chỉnh ảnh | File nguồn riêng của phần mềm; PNG/WebP xuất | Có thể dùng ngoài repo; chưa cấu hình pipeline tự động |
| Audacity/DAW | Cắt, xử lý, mix SFX/nhạc | WAV/FLAC nguồn; OGG xuất cho game | Chưa có audio source project trong repo |
| AI image/audio tools | Tạo bản nháp concept, sprite, nền và âm thanh | PNG/WebP, WAV/OGG cùng prompt/metadata | Asset cuối cần người dùng duyệt |
| TypeScript/Node.js | Công cụ web phụ trợ hoặc pipeline riêng nếu có nhu cầu | `.ts`, `.js`, `.json`, HTML/CSS | Chưa có Node build pipeline |

Không cần dùng tất cả công cụ. Chỉ thêm dependency khi có nhu cầu cụ thể và có cách kiểm thử/đóng gói rõ ràng.

## 4. Quy ước định dạng file

### Runtime Godot

- `.gd`: GDScript runtime.
- `.tscn`: scene dạng text.
- `.tres`: resource dạng text.
- `.res`, `.scn`: resource/scene nhị phân nếu thực sự cần.
- `.godot`: cấu hình project.
- `.import`: metadata do Godot sinh; không chỉnh tay nếu không có lý do.

### Data

- `.json`: nội dung game và cấu hình có schema/validator.
- Giữ ID entity ổn định; đường dẫn asset trong JSON phải trỏ tới file thực tế hoặc có fallback rõ ràng.
- Không nhúng logic thực thi tùy ý vào JSON.

### Art

- `.png`: định dạng runtime mặc định cho sprite và UI hiện tại.
- `.webp`: có thể dùng làm file nguồn/ảnh web; chỉ dùng runtime khi import/export target đã xác minh tương thích.
- `.aseprite`, `.kra`, `.psd`, `.blend`: file nguồn chỉnh sửa; không mặc định được game runtime nạp trực tiếp.
- `.svg`: phù hợp logo/vector UI khi pipeline import đã kiểm tra.

### Audio

- `.ogg`: định dạng runtime được AudioManager tìm kiếm hiện tại.
- `.wav` hoặc `.flac`: phù hợp làm file nguồn chỉnh sửa; cần export sang định dạng runtime đã cấu hình.
- Không commit nhạc/SFX có bản quyền nếu chưa có quyền sử dụng.

### Tools/Web/CI

- `.py`: công cụ và kiểm thử Python.
- `.html`, `.css`, `.js`: HTML shell hoặc công cụ web.
- `.yml`/`.yaml`: workflow và cấu hình CI.
- `.md`: tài liệu, hướng dẫn, checklist.

## 5. Cấu trúc thư mục đề xuất khi mở rộng

Chỉ tạo thư mục khi có file thực tế cần quản lý:

~~~text
/
├── project.godot                 # Runtime Godot hiện tại
├── scenes/                       # Scene Godot
├── core/                         # Hệ thống lõi Godot
├── behaviors/                    # Hành vi runtime Godot
├── data/                         # JSON data trung lập engine
├── assets/
│   ├── source/                   # File nguồn art/audio, nếu cần lưu trong Git
│   ├── plants/                   # Sprite runtime
│   ├── zombies/                  # Sprite runtime
│   ├── backgrounds/              # Background runtime
│   ├── ui/                       # UI runtime
│   └── audio/                    # OGG runtime
├── tools/                        # Python và tool tự động hóa
├── web/                          # HTML shell và tài nguyên web
├── docs/                         # Architecture, pipeline, QA
└── unity/                        # Chỉ tạo khi thật sự thêm Unity project
~~~

Nếu file nguồn lớn hoặc cần lịch sử phiên bản riêng, có thể dùng Git LFS sau khi thống nhất quy tắc. Không tự động đưa cache, file export, build output hoặc file tạm vào Git.

## 6. Quy tắc phối hợp Godot và Unity

Có thể duy trì cả hai engine trong cùng một repository, nhưng cần coi chúng là hai runtime riêng:

- Godot project ở root vẫn là runtime chính hiện tại.
- Unity project (nếu được thêm sau này) nằm trong `unity/` và có tối thiểu `Assets/`, `Packages/manifest.json`, `ProjectSettings/`.
- Dữ liệu dùng chung nên là JSON có schema trung lập engine; tránh để hai engine tự sửa cùng một file theo hai quy tắc khác nhau.
- Asset nguồn có thể dùng chung nếu định dạng tương thích; mỗi engine có import settings riêng.
- Không copy C# Unity vào `core/` hoặc `behaviors/` của Godot.
- Tách workflow CI: Godot workflow kiểm tra Godot; Unity workflow cần Unity Editor version, license/activation phù hợp và test/build riêng.
- Chỉ đặt Unity là runtime phát hành khi đã có scene, gameplay, build target và QA Unity thực sự. Không tuyên bố hỗ trợ Unity chỉ vì có tài liệu C# tham khảo.

## 7. Quy trình đề xuất cho một nội dung mới

1. Thiết kế ý tưởng và đặc tả gameplay trong Markdown.
2. Tạo/duyệt concept bằng công cụ hình ảnh hoặc AI.
3. Giữ file nguồn chỉnh sửa nếu cần; xuất PNG/OGG theo định dạng runtime.
4. Khai báo thông số và tham chiếu bằng JSON theo schema hiện tại.
5. Dùng Python validator kiểm tra ID, field, số liệu và tham chiếu.
6. Viết logic trong runtime đang chọn (hiện tại là GDScript/Godot).
7. Chạy Godot import, headless startup, test gameplay và Web export.
8. Nếu có runtime Unity hoặc công cụ khác, chạy thêm pipeline kiểm thử riêng của nó.

## 8. Quy tắc đặt tên

- Tên file code theo vai trò và hệ thống: `WaveManager.gd`, `PlantBehavior.gd`, `validate_project.py`.
- Dùng chữ thường và dấu gạch ngang cho ID asset/data: `cuong-thi-thuong.json`, `music-horde.ogg`.
- Không đặt tên file theo phần mềm nếu nội dung không phụ thuộc phần mềm.
- File nguồn và file runtime nên phân biệt rõ, ví dụ `truc-tien.aseprite` là nguồn, `truc-tien.png` là asset runtime.
- Không đổi tên đường dẫn đã được JSON, scene, script hoặc workflow tham chiếu nếu chưa cập nhật toàn bộ tham chiếu và chạy validator.

## 9. Giới hạn hiện tại

- Runtime game trong repository: Godot 4.2+.
- Ngôn ngữ runtime hiện tại: GDScript.
- Công cụ code ngoài runtime: Python.
- Dữ liệu nội dung: JSON.
- Web shell: HTML.
- Chưa có Unity project độc lập, Blender source, Aseprite source hoặc audio DAW project trong repo.
- Chưa có CI build Unity hoặc kiểm tra tự động các phần mềm đồ họa/âm thanh bên ngoài.
