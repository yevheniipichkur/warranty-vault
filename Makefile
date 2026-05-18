SCHEME ?= WarrantyVault
PROJECT ?= WarrantyVault.xcodeproj
DESTINATION ?= platform=iOS Simulator,name=iPhone 16
ARCHIVE_PATH ?= build/archive/WarrantyVault.xcarchive
EXPORT_PATH ?= build/ipa

.PHONY: generate build test archive ipa clean

generate:
	bash Scripts/generate_project.sh

build: generate
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination "$(DESTINATION)" -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build

test: generate
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -destination "$(DESTINATION)" -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO test

archive: generate
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Release -destination "generic/platform=iOS" -archivePath "$(ARCHIVE_PATH)" archive

ipa: generate
	bash Scripts/build_ipa.sh

clean:
	rm -rf build WarrantyVault.xcodeproj
