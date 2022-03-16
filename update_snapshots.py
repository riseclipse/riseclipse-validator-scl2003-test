import os
from argparse import ArgumentParser
from utils import SCRIPTS_DIR, run_script

if __name__ == "__main__":
    parser = ArgumentParser(
        description="Update snapshots for given SCL files with their corresponding configuration"
    )
    parser.add_argument(
        "-j",
        "--jar-path",
        help="Optional path to the SCL validator jar. If omitted, this script will assume that the validator repository is located next to the testing repository.",
    )
    parser.add_argument(
        "scl_files",
        nargs="*",
        help="Optional list of SCL files to update snapshots for. If omitted, snapshots for all SCL files under the 'scl' directory will be updated.",
    )

    script = os.path.join(SCRIPTS_DIR, "update_snapshots.sh")
    args = parser.parse_args()
    run_script(script, args)
