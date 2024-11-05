ifeq ($(VAR_DIR),)
VAR_DIR=var/
endif

ifeq ($(CACHE_DIR),)
CACHE_DIR=$(VAR_DIR)cache/
endif

ifeq ($(PACKAGE_DIR),)
PACKAGE_DIR=package/
endif
