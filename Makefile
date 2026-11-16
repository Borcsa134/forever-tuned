.PHONY: install

ADDON_DIR = /Applications/World of Warcraft/_forever_/Interface/AddOns/ForeverTuned

install:
	@echo "Installing ForeverTuned addon..."
	@mkdir -p "$(ADDON_DIR)"
	@cp -r *.toc *.lua modules "$(ADDON_DIR)/"
	@echo "ForeverTuned installed successfully to $(ADDON_DIR)"
