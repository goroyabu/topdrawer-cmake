"""Isolated installation setup shared by the three installed-behavior checks."""

import argparse
import contextlib
import os
import pathlib
import subprocess
import tempfile
from dataclasses import dataclass


@dataclass
class Installation:
    cmake: str
    build_dir: pathlib.Path
    stage: pathlib.Path
    prefix: pathlib.Path
    work_dir: pathlib.Path
    executable: pathlib.Path
    help_file: pathlib.Path
    manifest: pathlib.Path
    env: dict


def arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cmake", required=True)
    parser.add_argument("--build-dir", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--bindir", required=True)
    parser.add_argument("--datarootdir", required=True)
    return parser.parse_args()


def run_command(command, *, cwd, env, timeout=30):
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            errors="replace",
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired as error:
        raise AssertionError(f"Command timed out: {command!r}") from error
    if result.returncode != 0:
        raise AssertionError(
            f"Command failed ({result.returncode}): {command!r}\n{result.stdout}"
        )
    return result.stdout


def staged_path(stage, prefix, install_dir, filename):
    destination = pathlib.Path(install_dir)
    if not destination.is_absolute():
        destination = prefix / destination
    return stage / str(destination).lstrip("/") / filename


@contextlib.contextmanager
def installed_td(args):
    build_dir = pathlib.Path(args.build_dir).resolve(strict=True)
    manifest = build_dir / "install_manifest.txt"
    previous_manifest = manifest.read_bytes() if manifest.exists() else None
    try:
        with tempfile.TemporaryDirectory(prefix="td-install-test-") as directory:
            root = pathlib.Path(directory)
            stage = root / "stage"
            work_dir = root / "work"
            home_dir = root / "home"
            for path in (stage, work_dir, home_dir):
                path.mkdir()

            prefix = pathlib.Path("/td-install-test")
            env = os.environ.copy()
            env["DESTDIR"] = str(stage)
            env["HOME"] = str(home_dir)
            env.pop("DISPLAY", None)
            env.pop("TD_HELP", None)

            run_command(
                [args.cmake, "--install", str(build_dir), "--prefix", str(prefix)],
                cwd=work_dir,
                env=env,
            )
            entries = manifest.read_text(encoding="utf-8").splitlines()
            if not entries:
                raise AssertionError("Install manifest is empty")
            for entry in entries:
                if not pathlib.Path(entry).is_absolute():
                    raise AssertionError(f"Unsafe relative install path: {entry}")
                (stage / entry.lstrip("/")).resolve().relative_to(stage.resolve())

            yield Installation(
                cmake=args.cmake,
                build_dir=build_dir,
                stage=stage,
                prefix=stage / str(prefix).lstrip("/"),
                work_dir=work_dir,
                executable=staged_path(stage, prefix, args.bindir, "td"),
                help_file=staged_path(
                    stage, prefix, args.datarootdir, "td/topdrawer.gih"
                ),
                manifest=manifest,
                env=env,
            )
    finally:
        if previous_manifest is None:
            manifest.unlink(missing_ok=True)
        else:
            manifest.write_bytes(previous_manifest)
