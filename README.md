# utsutsu2d

A pure Dart puppet animation library for Flutter, inspired by [Inochi2D](https://inochi2d.com/) and its Rust implementation [inox2d](https://github.com/Inochi2D/inox2d).

Loads and renders `.inp` (Inochi2D Puppet) and `.inx` (Inochi2D eXtended) model files with support for:

- Blend shapes and parameter-driven animation
- JSON-based animation playback

## Requirements

- Flutter 3.10+ (Dart 3.0+)
- Apple Silicon (M1 Mac) tested

## Usage

Add to your `pubspec.yaml`:

```yaml
dependencies:
  utsutsu2d:
    git:
      url: https://github.com/sawarae/utsutsu2d.git
```

Load and display a puppet:

```dart
import 'package:utsutsu2d/utsutsu2d.dart';

// Load a model
final puppet = await ModelLoader.load('path/to/model.inp');

// Use PuppetWidget to render
PuppetWidget(puppet: puppet)
```

## GUI Viewer

A standalone viewer app is included in `gui/`:

```bash
cd gui
flutter run -d macos
```

## Credits

- Inspired by [Inochi2D](https://inochi2d.com/) by the Inochi2D Project
- Rust reference implementation: [inox2d](https://github.com/Inochi2D/inox2d)

## Known Issues

- **inox2d opacity bindings**: `BindingValues::Opacity` is unimplemented in inox2d (`params.rs` — `// TODO` no-op). Our INP format is spec-compliant, but opacity-driven blend shapes (e.g. expression switching) do not render in inox2d. Works correctly in utsutsu2d's Dart renderer.


## つくよみちゃんについて

このアプリでは、フリー素材キャラクター「[つくよみちゃん](https://tyc.rei-yumesaki.net/)」（© Rei Yumesaki）を使用しています。

### （公式）つくよみちゃん万能立ち絵素材

- **素材制作者:** 花兎\*
- **素材配布URL:** <https://tyc.rei-yumesaki.net/material/illust/>
- **利用規約:** <https://tyc.rei-yumesaki.net/about/terms/>

### （公式）つくよみちゃん万能ミニキャラ素材

- **素材制作者:** きばやし
- **素材配布URL:** <https://tyc.rei-yumesaki.net/material/illust/>
- **利用規約:** <https://tyc.rei-yumesaki.net/about/terms/>
- **ニコニコ静画:** [im11318256](https://seiga.nicovideo.jp/seiga/im11318256)

### 夢前月夜ちゃんが頑張る立ち絵
- **素材制作者:** ぴぴ
- **素材配布URL:** <https://seiga.nicovideo.jp/seiga/im11142602>
