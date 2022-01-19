usage() {
    printf "Usage: $0 [options...]\n\n"
    printf "Options:\n"
    printf -- "-h --help \t\t\tShow this help message\n"
    printf -- "-j --jar-path <JAR_PATH> \tPath to the SCL validator jar\n"
    printf -- "-o --ocl \t\t\tUse OCL validation\n"
    printf -- "--ocl-root-dir <DIR> \t\tPath to the OCL files root directory (default: 'ocl')\n"
    printf -- "--ocl-dirs <DIRS> \t\tPaths to the desired OCL directories, relative to the OCL root directory.\n"
    printf "\t\t\t\tPaths must be separated by columns (:), the whole root directory will be used by default\n"
    printf -- "-n --nsd \t\t\tUse NSD validation\n"
    printf -- "--nsd-root-dir <DIR> \t\tPath to the NSD files root directory (default: 'nsd')\n"
    printf -- "--nsd-dirs <DIRS> \t\tPaths to the desired NSD directories, relative to the NSD root directory.\n"
    printf "\t\t\t\tPaths must be separated by columns (:), the whole root directory will be used by default\n"
}

arg_required() {
    if [ -z "$2" ]; then
        echo "Option '$1' requires an argument." 1>&2
        exit 1
    fi
}

# Default OCL and NSD root directories
OCL_ROOT_DIR="ocl"
NSD_ROOT_DIR="nsd"

OPTS=$(getopt -o hj:on -l help,jar-path,ocl,ocl-root-dir:,ocl-dirs:,nsd,nsd-root-dir:,nsd-dirs: -- "$@")

eval set -- "$OPTS"

while true; do
    case "$1" in
        -h | --help)
            usage
            exit 0;;
        -j | --jar-path)
            arg_required "$1" "$2"
            JAR_PATH="$2"
            shift;;
        -o | --ocl)
            OCL=1;;
        --ocl-root-dir)
            arg_required "$1" "$2"
            OCL_ROOT_DIR="$2"
            shift;;
        --ocl-dirs)
            arg_required "$1" "$2"
            OCL_DIRS="$(echo -n "$2" |tr : ' ')"
            shift;;
        -n | --nsd)
            NSD=1;;
        --nsd-root-dir)
            arg_required "$1" "$2"
            NSD_ROOT_DIR="$2"
            shift;;
        --nsd-dirs)
            arg_required "$1" "$2"
            NSD_DIRS="$(echo -n "$2" |tr : ' ')"
            shift;;
        --) 
            shift
            break;;
        *)
            echo "Unrecognized option: $1"
            usage
            exit 1;;
    esac
    shift
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

# Retrieve SCL files paths
SCL_PATHS="$@"

if [ -z $SCL_PATHS ]; then
    if [ ! -d "scl/input" ] || [ -z $(ls -A "scl/input") ]; then
        printf "No test found.\n\n" 1>&2
        exit 1
    fi
    SCL_PATHS="scl/input/*"
fi

# Retrieve OCL files paths
if [ -z "$OCL" ]; then
    OCL_PATHS=""
elif [ -n "$OCL_DIRS" ]; then
    OCL_PATHS=""
    for directory in $OCL_DIRS; do
        OCL_PATHS="$OCL_PATHS $(find $OCL_ROOT_DIR/$directory -path *.ocl |tr '\n' ' ')"
    done
else
    OCL_PATHS=$(find $OCL_ROOT_DIR -path *.ocl |tr '\n' ' ')
fi

# Retrieve NSD files paths

if [ -z "$NSD" ]; then
    NSD_PATHS=""
elif [ -n "$NSD_DIRS" ]; then
    NSD_PATHS=""
    for directory in $NSD_DIRS; do
        NSD_PATHS="$NSD_PATHS $(find $NSD_ROOT_DIR/$directory -path *.nsd |tr '\n' ' ')"
    done
else
    NSD_PATHS=$(find $NSD_ROOT_DIR -path *.nsd |tr '\n' ' ')
fi
