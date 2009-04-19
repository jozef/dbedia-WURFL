
TMP_LIB_FOLDER=tmp/lib
WURFL_LIB_FOLDER=${TMP_LIB_FOLDER}/Mobile/Devices
WURFL_XML=${WURFL_LIB_FOLDER}/wurfl.xml

# ALL
all: ${WURFL_XML} ${WURFL_LIB_FOLDER}/IDs.pm ${WURFL_LIB_FOLDER}/byID/g/en/generic.pm

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
.PHONY: .clean
clean:
	rm -rf tmp/*
