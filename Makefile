# Bajada: generate the Xcode project, install on your iPhone + Apple Watch, run tests.
#
#   make setup TEAM_ID=ABCDE12345            generate Bajada.xcodeproj
#   make setup TEAM_ID=ABCDE12345 NO_HEALTHKIT=1   same, with HealthKit compiled out
#   make deploy                              build + install on iPhone and watch
#   make test                                PadelKit unit tests (also runs on Linux)

TEAM_ID      ?=
NO_HEALTHKIT ?=
IPHONE_ID    ?=
WATCH_ID     ?=

PROJECT   := Bajada.xcodeproj
BUILD_DIR := build
CONFIG    ?= Debug

NO_HK := $(filter 1 yes true YES TRUE,$(NO_HEALTHKIT))

.PHONY: setup generate check-xcodegen test deploy clean

check-xcodegen:
	@command -v xcodegen >/dev/null 2>&1 || { \
	  echo "xcodegen is not installed. Install it with:  brew install xcodegen"; exit 1; }

# Full setup for a person: needs the Apple Developer Team ID.
setup:
	@test -n "$(TEAM_ID)" || { \
	  echo "Usage: make setup TEAM_ID=<your team id> [NO_HEALTHKIT=1]"; \
	  echo "Find the ID in Xcode > Settings > Accounts > your Personal Team, or at"; \
	  echo "developer.apple.com/account > Membership details."; exit 1; }
	@$(MAKE) --no-print-directory generate TEAM_ID="$(TEAM_ID)" NO_HEALTHKIT="$(NO_HEALTHKIT)"
	@echo ""
	@echo "Done. Next: make deploy   (or open $(PROJECT) and press Run on each scheme)"

# Writes Local.xcconfig and runs xcodegen. TEAM_ID is optional here (CI has none).
generate: check-xcodegen
	@echo "// Written by 'make setup'. Gitignored: do not commit." > Local.xcconfig
	@if [ -n "$(TEAM_ID)" ]; then echo "DEVELOPMENT_TEAM = $(TEAM_ID)" >> Local.xcconfig; fi
ifneq ($(NO_HK),)
	@echo "BAJADA_WATCH_INFOPLIST = WatchApp/Info.NoHealthKit.plist" >> Local.xcconfig
	@echo "BAJADA_WATCH_ENTITLEMENTS = WatchApp/BajadaWatch.NoHealthKit.entitlements" >> Local.xcconfig
	@echo "BAJADA_SWIFT_FLAGS = -D NO_HEALTHKIT" >> Local.xcconfig
	@echo "HealthKit: OFF (entitlement, background mode and code removed)"
else
	@echo "HealthKit: ON"
endif
	xcodegen generate --spec project.yml

test:
	cd Packages/PadelKit && swift test

# NOTE: `deploy` has NOT been verified on real hardware. It follows Apple's
# documented xcodebuild + devicectl flow. If any step fails, the fallback is
# always: open Bajada.xcodeproj and press Run on each scheme (Bajada with the
# iPhone selected, BajadaWatch with the Ultra selected).
#
# Device UDIDs are auto-detected with `xcrun devicectl list devices`; override
# with IPHONE_ID=<udid> WATCH_ID=<udid>. Building for the specific devices (not a
# generic destination) lets Xcode register them with a free Personal Team.
deploy:
	@test -d $(PROJECT) || { echo "No $(PROJECT). Run: make setup TEAM_ID=<your team id>"; exit 1; }
	@iphone="$(IPHONE_ID)"; watch="$(WATCH_ID)"; \
	[ -n "$$iphone" ] || iphone=$$(python3 scripts/device_id.py iphone) || true; \
	[ -n "$$watch" ] || watch=$$(python3 scripts/device_id.py watch) || true; \
	if [ -z "$$iphone" ]; then \
	  echo "No iPhone found. Connect it, unlock it, or pass IPHONE_ID=<id> (xcrun devicectl list devices)."; \
	  echo "Or open $(PROJECT) and press Run on each scheme."; exit 1; \
	fi; \
	echo "iPhone: $$iphone"; echo "Watch:  $${watch:-not found}"; \
	if [ -n "$$watch" ]; then \
	  echo "==> Building BajadaWatch for the watch (registers it with your team)"; \
	  xcodebuild -project $(PROJECT) -scheme BajadaWatch -configuration $(CONFIG) \
	    -destination "id=$$watch" -derivedDataPath $(BUILD_DIR) \
	    -allowProvisioningUpdates build || watch=""; \
	fi; \
	echo "==> Building Bajada for the iPhone (the watch app is embedded)"; \
	xcodebuild -project $(PROJECT) -scheme Bajada -configuration $(CONFIG) \
	  -destination "id=$$iphone" -derivedDataPath $(BUILD_DIR) \
	  -allowProvisioningUpdates build \
	  || { echo "Build failed. If the error mentions HealthKit or provisioning, re-run: make setup TEAM_ID=... NO_HEALTHKIT=1"; \
	       echo "Or open $(PROJECT) and press Run on each scheme."; exit 1; }; \
	echo "==> Installing on the iPhone"; \
	xcrun devicectl device install app --device "$$iphone" \
	  $(BUILD_DIR)/Build/Products/$(CONFIG)-iphoneos/Bajada.app \
	  || { echo "iPhone install failed. Open $(PROJECT) and press Run on each scheme."; exit 1; }; \
	if [ -n "$$watch" ]; then \
	  echo "==> Installing on the watch"; \
	  xcrun devicectl device install app --device "$$watch" \
	    $(BUILD_DIR)/Build/Products/$(CONFIG)-watchos/BajadaWatch.app \
	    || echo "Watch step failed (the iPhone install normally carries the watch app too). Otherwise: open $(PROJECT) and press Run on the BajadaWatch scheme."; \
	else \
	  echo "No watch found: relying on the iPhone install to push the embedded watch app."; \
	  echo "If it does not appear: open $(PROJECT) and press Run on each scheme."; \
	fi; \
	echo "First time only: iPhone > Settings > General > VPN & Device Management > trust your developer profile."

clean:
	rm -rf $(BUILD_DIR)
