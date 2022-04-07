import sys
import os
import json
import subprocess
from collections import defaultdict
from collections.abc import Iterable
from argparse import Namespace
from typing import Optional

ROOT_DIR = os.path.dirname(os.path.realpath(__file__))
SCL_INPUT_DIR = os.path.join(ROOT_DIR, "scl", "input")
SCRIPTS_DIR = os.path.join(ROOT_DIR, "scripts")

Filename = str
Config = Optional[dict[str, str]]
FilesForConfig = tuple[Config, list[Filename]]


def get_all_scl_filenames() -> list[Filename]:
    """
    Returns the list of all SCL filenames in the 'scl' folder.

    Returns:
        list[Filename]: List of SCL filenames
    """

    all_filenames = []

    for root, _, filenames in os.walk(SCL_INPUT_DIR):
        abspath = lambda filename: f"{root}/{filename}"
        not_conf = lambda filename: not filename.endswith(".conf.json")
        all_filenames.extend(map(abspath, filter(not_conf, filenames)))

    return all_filenames


def get_scl_conf(filename: Filename) -> tuple[Filename, Config]:
    """
    Get the test config for a given SCL file.

    Args:
        filename (Filename): The SCL file to get config for

    Raises:
        FileNotFoundError: Error raised when the provided filename does not resolve to an existing file

    Returns:
        tuple[Filename, Config]: A tuple containing the filename and its test config
    """

    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find SCL file '{filename}'")

    conf_filename = f"{os.path.splitext(filename)[0]}.conf.json"

    if not os.path.isfile(conf_filename):
        return (filename, None)

    with open(conf_filename, "r") as f:
        conf = json.load(f)

    return (filename, conf)


def grouped_scl_confs(scl_confs: list[tuple[Filename, Config]]) -> list[FilesForConfig]:
    """
    Groups test configurations with the SCL files that use them.

    Args:
        scl_confs (list[tuple[Filename, Config]]): List of (filename, config) tuples

    Returns:
        list[FilesForConfig]: List of configurations mapped to the files that use them
    """

    by_conf = defaultdict(list)

    for filename, conf in scl_confs:
        if conf is None:
            conf_key = None
        else:
            sorted_conf_items = map(
                lambda item: (item[0], tuple(sorted(item[1])))
                if isinstance(item[1], Iterable)
                else item,
                conf.items(),
            )
            conf_key = frozenset(sorted_conf_items)
        by_conf[conf_key].append(filename)

    grouped_confs = []

    for conf_key, filenames in by_conf.items():
        conf = None if conf_key is None else dict(conf_key)
        grouped_confs.append((conf, filenames))

    return grouped_confs


def command_to_run(
    script: str, jar_path: Optional[str], files_for_config: FilesForConfig
) -> str:
    """
    Returns the command to be run with the given script, jar path and file config settings.

    Args:
        script (str): Path to the script to be used
        jar_path (Optional[str]): Path to the jar used by the script
        files_for_config (FilesForConfig): List of configurations mapped to the files that use them

    Returns:
        str: Command string which can then be run in a subprocess
    """

    base_command = f"{script} --jar-path {jar_path}" if jar_path is not None else script
    config, scl_filenames = files_for_config
    scl_filenames = map(lambda file: f'"{file}"', scl_filenames)
    scl_files_string = " ".join(scl_filenames)

    if config is None:
        return f"{base_command} -o -n {scl_files_string}"

    ocl_option = ""
    if "ocl" in config:
        ocl_option += "-o"
        if "*" not in config["ocl"]:
            ocl_option += ":".join(config["ocl"])
        del config["ocl"]

    nsd_option = ""
    if "nsd" in config:
        nsd_option += "-n"
        if "*" not in config["nsd"]:
            nsd_option += ":".join(config["nsd"])
        del config["nsd"]

    jar_options = ""
    for opt, val in config.items():
        if val == 1:
            jar_options += f"--{opt} "

    return f"{base_command} {ocl_option} {nsd_option} {jar_options} {scl_files_string}"


def run_script(script: str, args: Namespace) -> None:
    """
    Runs the given script as many times as necessary with arguments derived from the provided arguments.

    Args:
        script (str): Path to the script to be used
        args (Namespace): Command line args parsed by the calling script.
            Expected arguments are :
            - scl_files: List of SCL files to run the script on (defaults to None)
            - jar_path: Jar path passed on to the script (defaults to None)
    """

    scl_filenames = args.scl_files if args.scl_files else get_all_scl_filenames()
    confs = list(map(get_scl_conf, scl_filenames))
    grouped_confs = grouped_scl_confs(confs)

    for files_for_config in grouped_confs:
        command = command_to_run(script, args.jar_path, files_for_config)
        print(f"> {command}")
        completed_process = subprocess.run(command, shell=True)

        if (return_code := completed_process.returncode) != 0:
            print(f"Command failed, exited with code {return_code}")
            sys.exit(return_code)
