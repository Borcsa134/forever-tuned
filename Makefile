.PHONY: install

ADDON_DIR = /Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverTweaks

install:
	@echo "Installing ForeverTweaks addon..."
	@mkdir -p "$(ADDON_DIR)"
	@cp -r *.toc *.lua "$(ADDON_DIR)/"
	@echo "ForeverTweaks installed successfully to $(ADDON_DIR)"
