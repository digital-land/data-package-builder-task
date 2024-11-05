all::

include makerules/makerules.mk
include makerules/datapackage.mk

organisation-package:: $(PACKAGE_DIR)organisation.csv $(PACKAGE_DIR)organisation-check.csv

ifneq ($(READ_S3_BUCKET),)
save-organisation-package:: organisation-package
	@echo Saving package to S3 bucket $(WRITE_S3_BUCKET)
	aws s3 sync $(PACKAGE_DIR) s3://$(WRITE_S3_BUCKET)/organisation-package/$(PACKAGE_DIR)--no-progress
else
save-organisation-package:: organisation-package
	@echo WRITE_S3_BUCKET not set. Package will not be saved.
endif

$(CACHE_DIR)local-planning-authority.csv:
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://files.planning.data.gov.uk/dataset/local-planning-authority.csv" > $(CACHE_DIR)local-planning-authority.csv

ifneq ($(READ_S3_BUCKET),)
$(PACKAGE_DIR)organisation.csv:
	@echo Building organisation data package - using collection files from S3 bucket $(READ_S3_BUCKET)
	@mkdir -p $(PACKAGE_DIR)
	@mkdir -p $(CACHE_DIR)/organisation-collection/dataset 
	@aws s3 sync s3://$(READ_S3_BUCKET)/organisation-collection/dataset $(CACHE_DIR)/organisation-collection/dataset/ --no-progress
	digital-land organisation-create
		--dataset-dir $(CACHE_DIR)/organisation-collection/dataset \
		--output-path $(PACKAGE_DIR)/organisation.csv
else
$(PACKAGE_DIR)organisation.csv:
	@echo Building organisation data package - using collection files from CDN
	@mkdir -p $(PACKAGE_DIR)
	digital-land organisation-create \
		--cache-dir $(CACHE_DIR)/organisation-collection/dataset \
		--download-url 'https://files.planning.data.gov.uk/organisation-collection/dataset' \
		--output-path $(PACKAGE_DIR)/organisation.csv
endif

$(PACKAGE_DIR)organisation-check.csv: $(PACKAGE_DIR)organisation.csv $(CACHE_DIR)local-planning-authority.csv
	digital-land organisation-check --input-path $(PACKAGE_DIR)organisation.csv --output-path $@
