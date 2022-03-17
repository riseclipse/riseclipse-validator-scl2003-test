import sys
import os
import json
import subprocess
from collections import defaultdict
from argparse import Namespace
from typing import Optional

ROOT_DIR = os.path.dirname(os.path.realpath(__file__))
SCL_INPUT_DIR = os.path.join(ROOT_DIR, "scl", "input")
SCRIPTS_DIR = os.path.join(ROOT_DIR, "scripts")

Filename = str
Config = Optional[dict[str, str]]
FilesForConfig = tuple[Config, list[Filename]]


def get_all_scl_filenames() -> list[Filename]:
    all_filenames = []

    for root, _, filenames in os.walk(SCL_INPUT_DIR):
        abspath = lambda filename: f"{root}/{filename}"
        not_conf = lambda filename: not filename.endswith(".conf.json")
        all_filenames.extend(map(abspath, filter(not_conf, filenames)))

    return all_filenames


def get_scl_conf(filename: Filename) -> tuple[Filename, Config]:
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find SCL file '{filename}'")

    conf_filename = f"{os.path.splitext(filename)[0]}.conf.json"

    if not os.path.isfile(conf_filename):
        return (filename, None)

    with open(conf_filename, "r") as f:
        conf = json.load(f)

    return (filename, conf)


def grouped_scl_confs(scl_confs: list[tuple[Filename, Config]]) -> list[FilesForConfig]:
    by_conf = defaultdict(list)

    for filename, conf in scl_confs:
        sorted_conf_items = map(
            lambda item: (item[0], tuple(sorted(item[1]))), conf.items()
        )
        conf_key = None if conf is None else frozenset(sorted_conf_items)
        by_conf[conf_key].append(filename)

    grouped_confs = []

    for conf_key, filenames in by_conf.items():
        conf = None if conf_key is None else dict(conf_key)
        grouped_confs.append((conf, filenames))

    return grouped_confs


def command_to_run(
    script: str, jar_path: Optional[str], files_for_config: FilesForConfig
) -> str:
    base_command = f"{script} --jar-path {jar_path}" if jar_path is not None else script
    config, scl_filenames = files_for_config
    scl_files_string = " ".join(scl_filenames)

    if config is None:
        return f"{base_command} --ocl --nsd {scl_files_string}"
    else:
        ocl_option = f"--ocl={':'.join(config['ocl'])}" if "ocl" in config else ""
        nsd_option = f"--nsd={':'.join(config['nsd'])}" if "nsd" in config else ""
        return f"{base_command} {ocl_option} {nsd_option} {scl_files_string}"


def run_script(script: str, args: Namespace) -> None:
    scl_filenames = args.scl_files if args.scl_files else get_all_scl_filenames()
    confs = list(map(get_scl_conf, scl_filenames))
    grouped_confs = grouped_scl_confs(confs)

    for files_for_config in grouped_confs:
        command = command_to_run(script, args.jar_path, files_for_config)
        print(f"> {command}")
        completed_process = subprocess.run(command.split(" "))

        if (return_code := completed_process.returncode) != 0:
            print(f"Command failed, exited with code {return_code}")
            sys.exit(return_code)
