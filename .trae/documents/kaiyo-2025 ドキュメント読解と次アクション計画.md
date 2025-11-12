## 方針と確定事項
- ローカル完結のFlutterアプリを新規セットアップ（FVM利用）。
- ローカルDBは Hive を採用。
- 学期判定は既存設計に準拠（`/Users/natsuhirosuzuki/Desktop/suzukioff/kaiyo-2025/docs/design.md:27-33`）。
- 単位は自然数、特殊条件（端数・クロス算入・優先度細則）は不採用。
- 区分マッピングは「厳格一致でなく可読一致」を前提に、正規化＋簡易エイリアスで対応。

## 修正と初期セットアップ
1. README内リンク修正：`docs/DESIGN.md`→`docs/design.md`（`README.md:73-76`）。
2. Flutterプロジェクト初期化：`pubspec.yaml`、`lib/`、`.fvm/` を生成。
3. FVM設定：最新安定版Flutterを使用。
4. 依存追加：`hive`, `hive_flutter`。
5. アセット登録：`pubspec.yaml` に `docs/*.json` を追加し、アプリから読み込み。

## ディレクトリ／ファイル構成（予定）
- `lib/main.dart`: エントリーポイントとルーティング。
- `lib/core/models/`: `user.dart`, `taken_course.dart`。
- `lib/core/repo/`: `curriculum_rules_repository.dart`, `courses_master_repository.dart`。
- `lib/core/services/`: `mapping_normalizer.dart`, `term_utils.dart`, `progression_calculator.dart`。
- `lib/features/onboarding/`: 初回起動フローUI。
- `lib/features/dashboard/`: 2タブ（不足／修得済み）。

## データ・モデル
- ユーザーデータ：`enrollmentYear:int`, `currentGrade:int`, `department:String`, `takenCourses:[{ courseName, credits:int, difficulty:(H/M/E), majorCategory, subCategory, isOverCredit:boolean }]`（任意で `courseId?`）。
- ルール／科目マスタ：既存JSON（ENG/LOG/CAP）をアセットからロード。

## マッピング仕様（可読一致）
1. 正規化：大文字小文字、全角半角、記号・空白の除去／統一。
2. エイリアス：和英表記差や略称の簡易辞書（例："Basic English"≒"基礎英語"）。
3. マッチング：`majorCategory/subCategory` と `requiredLimits` の最良一致（曖昧時はサブカテゴリ優先）。

## ロジック実装
- 学期判定ユーティリティ（既存ロジック準拠）。
- 進級／卒業算入：区分上限に基づく算入、超過分は `isOverCredit=true` として除外。
- 指定科目の修得チェック（3年進級など）。

## UI実装
- 初回起動フロー：学科・学年登録→過去単位入力→メインへ。
- メイン：2タブ（不足単位ビュー／修得済みビュー）。
- 不足内訳ダイアログと指定科目不足警告の表示。

## 検証（最小）
- ローカル起動し、ENG/LOG/CAPの代表ケースで不足単位が表示されることを手動確認。

## マイルストーン
- Phase 1: リンク修正／Flutter+FVM初期化／Hive導入／アセット設定。
- Phase 2: モデル／リポジトリ／マッピング正規化の実装。
- Phase 3: 算入ロジック／学期判定の実装。
- Phase 4: 画面（初回フロー／メインタブ／ダイアログ）と動作確認。