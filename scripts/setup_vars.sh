. "$SCRIPTS_DIR/utils.sh"

SCL_ROOT_DIR="$ROOT_DIR/scl"
OCL_ROOT_DIR="$ROOT_DIR/ocl"
NSD_ROOT_DIR="$ROOT_DIR/nsd"

usage() {
    printf "Usage: $0 [OPTION...] [SCL_FILE...]\n\n"
    printf "If you want to validate specific SCL files, provide their paths separated by spaces after the options.\n"
    printf "By default, all files under the '$SCL_ROOT_DIR/input' directory will be validated.\n\n"
    printf "Options:\n"
    printf -- "-h --help              \t\tShow this help message\n"
    printf -- "-j --jar-path <JAR_PATH> \tPath to the SCL validator jar\n"
    printf -- "-o[PATHS] --ocl[=PATHS]  \tUse OCL validation. The optional PATHS argument is a column (:) separated list of relative paths to include OCL files from.\n"
    printf                       "\t\t\t\tThese paths are relative to the '$OCL_ROOT_DIR' directory, so make sure your OCL files are inside of it.\n"
    printf                       "\t\t\t\tPaths can either be directories which will be searched recursively, or full paths to OCL files.\n"
    printf                       "\t\t\t\tBy default, all files under the '$OCL_ROOT_DIR' directory will be used for validation.\n"
    printf -- "-n[PATHS] --nsd[=PATHS]  \tUse NSD validation. The optional PATHS argument is a column (:) separated list of relative paths to include NSD files from.\n"
    printf                       "\t\t\t\tThese paths are relative to the '$NSD_ROOT_DIR' directory, so make sure your NSD files are inside of it.\n"
    printf                       "\t\t\t\tPaths can either be directories which will be searched recursively, or full paths to NSD files.\n"
    printf                       "\t\t\t\tBy default, all files under the '$NSD_ROOT_DIR' directory will be used for validation.\n"
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
                OCL_RELATIVE_DIRS=$(echo -n "$2" |tr : ' ')
                OCL_DIRS=""
                for directory in $OCL_RELATIVE_DIRS; do
                    OCL_DIRS="$OCL_DIRS $OCL_ROOT_DIR/$directory"
                done
            fi
            shift;;
        -n | --nsd)
            NSD=1
            if [ -n "$2" ]; then
                NSD_RELATIVE_DIRS=$(echo -n "$2" |tr : ' ')
                NSD_DIRS=""
                for directory in $NSD_RELATIVE_DIRS; do
                    NSD_DIRS="$NSD_DIRS $NSD_ROOT_DIR/$directory"
                done
            fi
            shift;;
        --) 
            shift
            break;;
        *)
            echo "Unrecognized option: $1" 1>&2
            usage
            exit 1;;
    esac
    shift
done

# Use default jar path if none was provided
if [ -z "$JAR_PATH" ]; then
    VALIDATOR_ROOT="$ROOT_DIR/../riseclipse-validator-scl2003/fr.centralesupelec.edf.riseclipse.iec61850.scl.validator"
    VALIDATOR_VERSION=$(grep -oPm1 '(?<=version>)[^<]*' $VALIDATOR_ROOT/pom.xml)
    JAR_NAME="RiseClipseValidatorSCL-${VALIDATOR_VERSION}.jar"
    JAR_PATH="$VALIDATOR_ROOT/target/$JAR_NAME"
fi

if [ ! -f "$JAR_PATH" ]; then
    echo "Invalid jar path: $JAR_PATH" 1>&2
    exit 1
fi

# Retrieve SCL files paths
SCL_PATHS="$@"

if [ -z "$SCL_PATHS" ]; then
    if [ ! -d "$SCL_ROOT_DIR/input" ] || [ -z $(ls -A "$SCL_ROOT_DIR/input") ]; then
        printf "No test found.\n\n" 1>&2
        exit 1
    fi
    SCL_PATHS="$SCL_ROOT_DIR/input/*"
fi

# Retrieve OCL files paths
if [ -z "$OCL" ]; then
    OCL_PATHS=""
elif [ -n "$OCL_DIRS" ]; then
    OCL_PATHS=""
    for path in $OCL_DIRS; do
        if [ -f "$path" ]; then
            OCL_PATHS="$OCL_PATHS $path"
            continue
        fi

        if [ ! -d "$path" ]; then
            printf "Path '$path' not recognized.\nPlease provide valid paths for OCL validation.\n" 1>&2
            exit 1
        fi

        OCL_PATHS="$OCL_PATHS $(find $path -path *.ocl |tr '\n' ' ')"
    done
elif [ -d "$OCL_ROOT_DIR" ]; then
    OCL_PATHS=$(find $OCL_ROOT_DIR -path *.ocl |tr '\n' ' ')
else
    echo "Directory '$OCL_ROOT_DIR' was not found, cannot use OCL validation." 1>&2
    exit 1
fi

# Retrieve NSD files paths
if [ -z "$NSD" ]; then
    NSD_PATHS=""
elif [ -n "$NSD_DIRS" ]; then
    NSD_PATHS=""
    for path in $NSD_DIRS; do
        if [ -f "$path" ]; then
            NSD_PATHS="$NSD_PATHS $path"
            continue
        fi

        if [ ! -d "$path" ]; then
            printf "Path '$path' not recognized.\nPlease provide valid paths for NSD validation.\n" 1>&2
            exit 1
        fi

        NSD_PATHS="$NSD_PATHS $(find $path -path *.xsd |tr '\n' ' ')"
    done
elif [ -d "$NSD_ROOT_DIR" ]; then
    NSD_PATHS=$(find $NSD_ROOT_DIR -path *.nsd |tr '\n' ' ')
else
    echo "Directory '$NSD_ROOT_DIR' was not found, cannot use NSD validation." 1>&2
    exit 1
fi
