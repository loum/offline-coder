.SILENT:
.DEFAULT_GOAL := help

#
# Makester overrides.
#
MAKESTER__STANDALONE := true
MAKESTER__INCLUDES := py docs
MAKESTER__PROJECT_NAME := offline-coder

include $(HOME)/.makester/makefiles/makester.mk

help: makester-help
	@echo "(Makefile)\n"
