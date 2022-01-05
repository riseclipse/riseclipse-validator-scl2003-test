if [ $# -ne 1 ]; then
    echo "Usage: $0 [scl|ocl|nsd]" 1>&2
    exit 1
fi

case $1 in
scl)
    VALIDATOR_ROOT=../riseclipse-validator-scl2003/fr.centralesupelec.edf.riseclipse.iec61850.scl.validator
    VALIDATOR_VERSION=$(grep -oPm1 '(?<=version>)[^<]*' $VALIDATOR_ROOT/pom.xml)
    JAR_NAME=RiseClipseValidatorSCL-${VALIDATOR_VERSION}.jar;;
ocl)
    JAR_NAME=blabla;;
nsd)
    JAR_NAME=blabla;;
*)
    echo "Argument '$1' not recognized. Usage: $0 [scl|ocl|nsd]" 1>&2
    exit 1;;
esac

JAR_PATH=$VALIDATOR_ROOT/target/$JAR_NAME

if [ ! -f $JAR_PATH ]; then
    echo "Invalid jar path: $JAR_PATH" 1>&2
    exit 1
fi
