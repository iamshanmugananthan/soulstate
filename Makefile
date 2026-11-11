# Makefile for Soul State (com.shanmugananthan.soulstate)

SHELL := /bin/bash
FLUTTER := $(shell which flutter 2>/dev/null || echo /opt/flutter/bin/flutter)
VERSION := 1.0.0
APP_NAME := soulstate
APP_ID := com.shanmugananthan.soulstate

.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help message
	@echo "Soul State Build System"
	@echo "======================="
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: pub-get
pub-get: ## Resolve Flutter dependencies
	@echo "--> Fetching dependencies..."
	$(FLUTTER) pub get

.PHONY: apk
apk: ## Build Android release APK
	@echo "--> Building Android release APK..."
	$(FLUTTER) build apk --release --no-tree-shake-icons
	@echo "APK generated at: build/app/outputs/flutter-apk/app-release.apk"

.PHONY: aab
aab: ## Build Android App Bundle (AAB)
	@echo "--> Building Android App Bundle (AAB)..."
	$(FLUTTER) build appbundle --release --no-tree-shake-icons
	@echo "AAB generated at: build/app/outputs/bundle/release/app-release.aab"

.PHONY: linux
linux: ## Build Linux release bundle
	@echo "--> Building Linux release binary..."
	$(FLUTTER) build linux --release

.PHONY: deb
deb: linux ## Package Linux release as Debian (.deb) package
	@echo "--> Packaging Debian package..."
	bash linux/package_deb.sh

.PHONY: appimage
appimage: linux ## Package Linux release as standalone AppImage
	@echo "--> Packaging Linux AppImage..."
	bash linux/package.sh

.PHONY: tarball
tarball: linux ## Package Linux release as portable tar.gz
	@echo "--> Creating portable Linux tarball..."
	mkdir -p build/linux/package/SoulState
	cp -r build/linux/x64/release/bundle/. build/linux/package/SoulState/
	tar -C build/linux/package -czf soulstate-$(VERSION)-linux-x64.tar.gz SoulState
	@echo "Tarball generated at: soulstate-$(VERSION)-linux-x64.tar.gz"

.PHONY: all-linux
all-linux: linux appimage deb tarball ## Build all Linux distribution packages (binary, AppImage, deb, tarball)
	@echo "--> All Linux packages successfully built."

.PHONY: all-release
all-release: apk all-linux ## Build all release artifacts (Android APK + all Linux packages)
	@echo "--> All release targets successfully generated."

.PHONY: test
test: ## Run unit and widget tests
	@echo "--> Running tests..."
	$(FLUTTER) test

.PHONY: fdroid
fdroid: fdroid-check apk ## Verify metadata and build F-Droid APK
	@echo "--> Preparing F-Droid release package..."
	@mkdir -p build/fdroid/repo
	@cp build/app/outputs/flutter-apk/app-release.apk build/fdroid/repo/$(APP_ID)_1.apk
	@echo "F-Droid APK ready at: build/fdroid/repo/$(APP_ID)_1.apk"

.PHONY: fdroid-check
fdroid-check: ## Verify F-Droid metadata recipe and Fastlane directory structure
	@echo "--> Verifying F-Droid and Fastlane structure..."
	@test -f .fdroid.yml && echo " [OK] .fdroid.yml exists" || (echo " [FAIL] .fdroid.yml missing"; exit 1)
	@test -f metadata/$(APP_ID).yml && echo " [OK] metadata/$(APP_ID).yml exists" || (echo " [FAIL] metadata/$(APP_ID).yml missing"; exit 1)
	@test -f fastlane/metadata/android/en-US/title.txt && echo " [OK] fastlane title.txt exists" || (echo " [FAIL] title.txt missing"; exit 1)
	@test -f fastlane/metadata/android/en-US/short_description.txt && echo " [OK] fastlane short_description.txt exists" || (echo " [FAIL] short_description.txt missing"; exit 1)
	@test -f fastlane/metadata/android/en-US/full_description.txt && echo " [OK] fastlane full_description.txt exists" || (echo " [FAIL] full_description.txt missing"; exit 1)
	@test -f fastlane/metadata/android/en-US/images/icon.png && echo " [OK] fastlane icon.png exists" || (echo " [FAIL] icon.png missing"; exit 1)
	@test -d fastlane/metadata/android/en-US/images/phoneScreenshots && echo " [OK] fastlane phoneScreenshots directory exists" || (echo " [FAIL] phoneScreenshots missing"; exit 1)
	@echo "--> F-Droid metadata check passed!"

.PHONY: clean
clean: ## Clean Flutter build cache and temporary packages
	@echo "--> Cleaning workspace..."
	$(FLUTTER) clean
	rm -rf build/
	rm -f *.AppImage *.deb *.tar.gz *.apk *.aab
