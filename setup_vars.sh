VALIDATOR_ROOT=../riseclipse-validator-scl2003/fr.centralesupelec.edf.riseclipse.iec61850.scl.validator
VALIDATOR_VERSION=$(grep -oPm1 '(?<=version>)[^<]*' $VALIDATOR_ROOT/pom.xml)
JAR_NAME=RiseClipseValidatorSCL-${VALIDATOR_VERSION}.jar
JAR_PATH=$VALIDATOR_ROOT/target/$JAR_NAME

if [ ! -f $JAR_PATH ]; then
    echo "Invalid jar path: $JAR_PATH" 1>&2
    exit 1
fi
