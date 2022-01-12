unset JAR_PATH
ARGS=$*

while getopts ":hj:" opt; do
    case "$opt" in
        h)
            usage
            exit 0;;
        j)
            JAR_PATH="$OPTARG"
            ARGS=${ARGS#-"$opt $OPTARG"};;
        *)
            usage
            exit 1;;
    esac
done

# Use default jar path if none was provided
if [ ! -v JAR_PATH ]; then
    VALIDATOR_ROOT=../riseclipse-validator-scl2003/fr.centralesupelec.edf.riseclipse.iec61850.scl.validator
    VALIDATOR_VERSION=$(grep -oPm1 '(?<=version>)[^<]*' $VALIDATOR_ROOT/pom.xml)
    JAR_NAME=RiseClipseValidatorSCL-${VALIDATOR_VERSION}.jar
    JAR_PATH=$VALIDATOR_ROOT/target/$JAR_NAME
fi

if [ ! -f $JAR_PATH ]; then
    echo "Invalid jar path: $JAR_PATH" 1>&2
    exit 1
fi

# By default, run tests for all formats, otherwise use the provided formats
if [ -z "$ARGS" ]; then
    formats='scl ocl nsd'
else
    formats="$ARGS"
fi
