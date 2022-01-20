OCL_DEFAULT_DIR=ocl
NSD_DEFAULT_DIR=nsd

usage() {
    printf "Usage: $0 [OPTION...] [SCL_FILE...]\n\n"
    printf "If you want to validate specific SCL files, provide their paths separated by spaces after the options.\n"
    printf "By default, all files under the 'scl/input' directory will be validated.\n\n"
    printf "Options:\n"
    printf -- "-h --help              \t\tShow this help message\n"
    printf -- "-j --jar-path <JAR_PATH> \tPath to the SCL validator jar\n"
    printf -- "-o[PATHS] --ocl[=PATHS]  \tUse OCL validation. The optional PATHS argument is a column (:) separated list of paths to include OCL files from.\n"
    printf                       "\t\t\t\tThose can either be directories which will be searched recursively, or full paths to OCL files.\n"
    printf                       "\t\t\t\tPATHS defaults to '$OCL_DEFAULT_DIR' if none is provided.\n"
    printf -- "-n[PATHS] --nsd[=PATHS]  \tUse NSD validation. The optional PATHS argument is a column (:) separated list of paths to include NSD files from.\n"
    printf                       "\t\t\t\tThose can either be directories which will be searched recursively, or full paths to NSD files.\n"
    printf                       "\t\t\t\tPATHS defaults to '$NSD_DEFAULT_DIR' if none is provided.\n"
}

arg_required() {
    if [ -z "$2" ]; then
        echo "Option '$1' requires an argument." 1>&2
        exit 1
    fi
}

OPTS=$(getopt -o hj:o::n:: -l help,jar-path,ocl::,,nsd:: -- "$@")

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
            OCL=1
            if [ -n "$2" ]; then
                OCL_DIRS=$(echo -n "$2" |tr : ' ')
            fi
            shift;;
        -n | --nsd)
            NSD=1
            if [ -n "$2" ]; then
                NSD_DIRS=$(echo -n "$2" |tr : ' ')
            fi
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
        OCL_PATHS="$OCL_PATHS $(find $directory -path *.ocl |tr '\n' ' ')"
    done
else
    OCL_PATHS=$(find $OCL_DEFAULT_DIR -path *.ocl |tr '\n' ' ')
fi

# Retrieve NSD files paths

if [ -z "$NSD" ]; then
    NSD_PATHS=""
elif [ -n "$NSD_DIRS" ]; then
    NSD_PATHS=""
    for directory in $NSD_DIRS; do
        NSD_PATHS="$NSD_PATHS $(find $directory -path *.nsd |tr '\n' ' ')"
    done
else
    NSD_PATHS=$(find $NSD_DEFAULT_DIR -path *.nsd |tr '\n' ' ')
fi
