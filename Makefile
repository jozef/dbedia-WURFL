
TMP_LIB_FOLDER=tmp/lib
WURFL_LIB_FOLDER=${TMP_LIB_FOLDER}/Mobile/Devices
WURFL_XML=${WURFL_LIB_FOLDER}/wurfl.xml
WWW_FOLDER=tmp/output

# ALL
.PHONY: all
all: ${WURFL_XML} ${WURFL_LIB_FOLDER}/IDs.pm ${WURFL_LIB_FOLDER}/byID/g/en/generic.pm ${WWW_FOLDER}/brandsModels.json ${WWW_FOLDER}/IDs.json

# install
.PHONY: install
install: all
	mkdir -p ${DESTDIR}/var/www/dbedia/WURFL
	cp -r ${WWW_FOLDER}/* ${DESTDIR}/var/www/dbedia/WURFL/
	mkdir -p ${DESTDIR}/etc/dbedia/sites-available
	cp etc/dbedia-WURFL.conf ${DESTDIR}/etc/dbedia/sites-available/

# WURFL byBrand JSON
${WWW_FOLDER}/IDs.json: ${WURFL_LIB_FOLDER}/IDs.pm ${WURFL_LIB_FOLDER}/byID/g/en/generic.pm
	mkdir -p ${WWW_FOLDER}
	script/dbedia-wurfl-bybrand.pl --lib tmp/lib --folder ${WWW_FOLDER}

# WURFL brands&models JSON
${WWW_FOLDER}/brandsModels.json: ${WURFL_LIB_FOLDER}/IDs.pm ${WURFL_LIB_FOLDER}/byID/g/en/generic.pm
	mkdir -p ${WWW_FOLDER}
	script/dbedia-wurfl-brands-models.pl --lib tmp/lib --folder ${WWW_FOLDER}

# UAs and IDs
${WURFL_LIB_FOLDER}/IDs.pm: ${WURFL_XML}
	mobile-devices-gen-list-of-uas-ids.pl --lib ${TMP_LIB_FOLDER}

# byID
${WURFL_LIB_FOLDER}/byID/g/en/generic.pm: ${WURFL_XML}
	mobile-devices-gen-by-id.pl --lib ${TMP_LIB_FOLDER}

# wurfl.xml
${WURFL_XML}:
	mkdir -p ${WURFL_LIB_FOLDER}
	mobile-devices-fresh-wurfl.pl --lib ${TMP_LIB_FOLDER}

# CLEAN
.PHONY: clean distclean
clean:
	rm -f ${WURFL_XML}

distclean:
	rm -rf tmp/*
