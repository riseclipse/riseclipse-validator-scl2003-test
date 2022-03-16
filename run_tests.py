import os
from argparse import ArgumentParser
from utils import SCRIPTS_DIR, run_script

if __name__ == "__main__":
    parser = ArgumentParser(
        description="Run tests for given SCL files with their corresponding configuration"
    )
    parser.add_argument(
        "-j",
        "--jar-path",
        help="Optional path to the SCL validator jar. If omitted, this script will assume that the validator repository is located next to the testing repository.",
    )
    parser.add_argument(
        "scl_files",
        nargs="*",
        help="Optional list of SCL files to validate. If omitted, all SCL files under the 'scl' directory will be validated.",
    )

    script = os.path.join(SCRIPTS_DIR, "run_tests.sh")
    args = parser.parse_args()
    run_script(script, args)
