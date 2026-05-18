# Warranty Vault

Нативное iOS-приложение на SwiftUI для хранения гарантий, чеков, серийных номеров, фото товаров и документов. Проект подготовлен так, чтобы его было удобно редактировать в Visual Studio Code, а финальную iOS-сборку делать на macOS через Xcode или GitHub Actions.

IPA в этой среде реально не собирался: проект был подготовлен на Windows, где нет Xcode, `xcodebuild` и `xcrun`. Для iPhone нужен macOS/Xcode runner и корректная Apple-подпись.

## 1. Что это за приложение

Warranty Vault — локальный “сейф гарантий”. Все данные остаются на устройстве: SwiftData хранит карточки товаров, изображения сохраняются в sandbox приложения, уведомления создаются через UserNotifications, PDF формируется локально.

В приложении нет AI, OpenAI API, Firebase, Supabase, backend, платных API и токенов.

## 2. Возможности приложения

- Добавление и редактирование товаров.
- Хранение бренда, модели, серийного номера, магазина, даты покупки, цены и заметок.
- Расчёт даты окончания гарантии.
- Статусы гарантии: активна, скоро истекает, истекла, без гарантии.
- Фото товара, чека и гарантийного документа через PhotosUI.
- Dashboard с общей статистикой.
- Поиск, фильтры и сортировка.
- Галерея чеков.
- Локальные напоминания.
- PDF export одного товара.
- StoreKit 2 placeholder для Pro-подписки.
- Free limit: до 10 items.
- Локализация: English, Polski, Українська, Русский.
- Тема приложения: System, Light, Dark.
- Live Activity для ближайшей гарантии.
- Скрытое DEBUG/QA меню.

## 3. Что уже реализовано

Реализован production-like MVP:

- SwiftUI app target `WarrantyVault`.
- Widget Extension `WarrantyVaultLiveActivity` для ActivityKit / Dynamic Island / Lock Screen.
- XcodeGen конфигурация `project.yml`.
- GitHub Actions workflow для macOS runner.
- Скрипты `Scripts/generate_project.sh` и `Scripts/build_ipa.sh`.
- Unit tests для расчёта гарантии, статусов, free limit, языка, темы и фильтров.
- Оригинальная AppIcon, сгенерированная без сторонних copyrighted assets.
- SwiftUI vector illustrations для onboarding и empty states.

## 4. Что нужно для разработки

Для редактирования на Windows/Linux:

- Visual Studio Code.
- Git.
- GitHub account, если хотите собирать через GitHub Actions.

Для локальной iOS-сборки:

- Mac.
- Xcode.
- XcodeGen.
- Apple Developer signing/provisioning для установки на реальный iPhone.

На Windows нельзя легально и штатно собрать iOS IPA локально. Используйте GitHub Actions `macos-latest` или любой Mac с Xcode.

## 5. Как открыть проект в VS Code

Откройте папку проекта:

```bash
code .
```

Редактировать можно все Swift-файлы, локализации, `project.yml`, README и скрипты. `.xcodeproj` генерируется позже на Mac или в GitHub Actions.

## 6. Как сгенерировать Xcode project через XcodeGen

На Mac:

```bash
brew install xcodegen
xcodegen generate
```

Или через готовый скрипт:

```bash
chmod +x Scripts/generate_project.sh
./Scripts/generate_project.sh
```

После генерации:

```bash
open WarrantyVault.xcodeproj
```

## 7. Как собрать через GitHub Actions

1. Создайте репозиторий на GitHub.
2. Запушьте проект.
3. Откройте вкладку `Actions`.
4. Запустите workflow `Build iOS IPA`.
5. Если signing secrets заполнены, workflow соберёт signed IPA.
6. Если secrets не заполнены, workflow соберёт simulator build и logs, но не будет выдавать fake IPA.

Workflow делает:

```text
checkout
install XcodeGen
generate WarrantyVault.xcodeproj
run tests
build simulator fallback или signed archive
export IPA при наличии подписи
upload artifacts
```

## 8. Как получить IPA

После успешного GitHub Actions run откройте страницу workflow run и скачайте artifact:

```text
WarrantyVault-signed-ipa
```

Логи сборки:

```text
WarrantyVault-build-logs
```

Если подпись не настроена, будет только:

```text
WarrantyVault-simulator-build
```

Simulator build не устанавливается на реальный iPhone.

## 9. Какие GitHub Secrets нужны

Для signed IPA добавьте в GitHub repository secrets:

```text
APPLE_TEAM_ID
BUNDLE_ID
CERTIFICATE_BASE64
CERTIFICATE_PASSWORD
PROVISIONING_PROFILE_BASE64
KEYCHAIN_PASSWORD
```

Пример создания base64 на Mac:

```bash
base64 -i Certificates.p12 | pbcopy
base64 -i YourProfile.mobileprovision | pbcopy
```

`BUNDLE_ID` должен быть вашим реальным bundle id, например:

```text
com.example.warrantyvault
```

Live Activity extension использует bundle id:

```text
com.example.warrantyvault.liveactivity
```

Для подписанной сборки extension тоже должен быть покрыт provisioning profile. Иногда подходит wildcard/development profile, но для production/Ad Hoc часто нужен отдельный App ID/profile для extension.

## 10. Как установить IPA на iPhone для теста

Корректные варианты:

- Development IPA: только на устройства, разрешённые вашим provisioning profile.
- Ad Hoc IPA: только на зарегистрированные UDID.
- TestFlight: лучший вариант для более широкого тестирования.

Высокоуровнево: скачайте signed IPA из GitHub Actions и установите через официальный/доверенный инструмент, который использует Apple signing rules. Не обходите Apple security и code signing.

Без Apple Developer Program установка на реальный iPhone может быть невозможна или сильно ограничена.

## 11. Ограничения без Mac

Без Mac нельзя:

- запустить Xcode;
- собрать `.xcodeproj` локально;
- сделать iOS archive;
- выполнить `exportArchive`;
- получить IPA прямо на Windows.

Можно:

- редактировать проект в VS Code;
- пушить в GitHub;
- собирать на GitHub Actions macOS runner;
- скачивать artifacts после CI.

## 12. Ограничения без Apple Developer Program

Без Apple Developer Program и корректной подписи:

- signed IPA для реального iPhone может не установиться;
- Ad Hoc распространение недоступно;
- TestFlight недоступен;
- Live Activity extension тоже требует корректного signing при device/archive сборке.

Simulator build можно получить без подписи, но это не IPA для iPhone.

## 13. Структура проекта

```text
WarrantyVault/App
WarrantyVault/Models
WarrantyVault/Views
WarrantyVault/ViewModels
WarrantyVault/Components
WarrantyVault/Services
WarrantyVault/Managers
WarrantyVault/Utilities
WarrantyVault/LiveActivity
WarrantyVault/Resources
WarrantyVault/Localization
WarrantyVaultLiveActivity
Tests/WarrantyVaultTests
Scripts
.github/workflows
```

Важные файлы:

```text
project.yml
Makefile
Scripts/build_ipa.sh
Scripts/generate_project.sh
ExportOptions.plist.example
.github/workflows/build-ipa.yml
```

## 14. Команды Makefile

На Mac:

```bash
make generate
make build
make test
make archive
make ipa
make clean
```

Если в Xcode нет simulator `iPhone 16`, укажите другой:

```bash
make test DESTINATION="platform=iOS Simulator,name=iPhone 15"
```

## 15. Скрытое отладочное меню

Debug / QA menu доступно только в `DEBUG` build. В `RELEASE` build вход не отображается пользователю.

Как открыть:

1. Откройте `Settings`.
2. Найдите секцию `About`.
3. Быстро тапните 7 раз по строке `App Version`.
4. Появится alert `Debug menu unlocked`.
5. В Settings появится секция/переход `Developer / QA`.

Возможности меню:

- Seed demo data.
- Clear all data.
- Reset onboarding.
- Toggle Pro locally.
- Reset Pro unlock.
- Trigger paywall.
- Test notifications.
- Create expiring warranty item.
- Create expired warranty item.
- Create no-warranty item.
- Test Live Activity.
- Stop Live Activity.
- Export test PDF.
- Show app paths.
- Localization test.
- Appearance test.
- Reset all app settings.

Деструктивные действия требуют подтверждения. Demo seed удаляет старые items с префиксом `Demo ` и создаёт их заново, чтобы не плодить бесконечные дубликаты.

## 16. Частые ошибки сборки

`xcodegen: command not found`

```bash
brew install xcodegen
```

`xcodebuild: command not found`

Установите Xcode и выберите developer directory:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

`No signing certificate`

Проверьте `CERTIFICATE_BASE64`, пароль сертификата и импорт в keychain.

`No provisioning profile`

Проверьте `PROVISIONING_PROFILE_BASE64`, `BUNDLE_ID`, `APPLE_TEAM_ID`. Для Live Activity extension проверьте профиль для `BUNDLE_ID.liveactivity`.

`Simulator iPhone 16 not found`

Укажите доступный simulator:

```bash
SIMULATOR_DESTINATION="platform=iOS Simulator,name=iPhone 15" ./Scripts/build_ipa.sh
```

`ExportOptions.plist missing`

Создайте файл из примера:

```bash
cp ExportOptions.plist.example ExportOptions.plist
```

И заполните Team ID, bundle IDs и provisioning profile names.

## 17. Что делать дальше

1. Поменять `APP_BUNDLE_ID` / `BUNDLE_ID` на свой bundle id.
2. Создать App ID и provisioning profiles в Apple Developer.
3. Проверить, что Live Activity extension тоже подписывается.
4. Запустить GitHub Actions без secrets, чтобы проверить simulator build.
5. Добавить signing secrets.
6. Запустить signed workflow.
7. Скачать `WarrantyVault-signed-ipa`.
8. Протестировать на зарегистрированном устройстве или через TestFlight.

На текущей машине IPA не был собран, потому что это Windows-среда без Xcode. Подготовлен workflow и проектная структура для реальной сборки на macOS.
