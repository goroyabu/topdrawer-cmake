"""Exercise PostScript output from the installed td executable."""

import os
import pathlib
import shutil

from common import arguments, installed_td, run_command


def main():
    args = arguments()
    with installed_td(args) as installation:
        executable = installation.executable
        if not executable.is_file() or not os.access(executable, os.X_OK):
            raise AssertionError(f"Installed td is missing or not executable: {executable}")

        input_path = installation.work_dir / "input.top"
        output_path = installation.work_dir / "input.ps"
        shutil.copyfile(pathlib.Path(args.input), input_path)
        env = installation.env.copy()
        env["TOPDRAWER_OUTPUT"] = output_path.name
        output = run_command(
            [str(executable), "-d", "postscr", str(input_path)],
            cwd=installation.work_dir,
            env=env,
            timeout=15,
        )
        for error in ("*** ERROR ***", "ERROR FOUND BY THE UNIFIED GRAPHICS SYSTEM"):
            if error in output:
                raise AssertionError(f"Installed td reported an error:\n{output}")
        if not output_path.is_file() or output_path.stat().st_size == 0:
            raise AssertionError(f"Installed td did not create {output_path}")
        postscript = output_path.read_bytes()
        if not postscript.startswith(b"%!PS-Adobe"):
            raise AssertionError("Installed td output lacks a PostScript header")
        for marker in (b"%%BoundingBox:", b"showpage"):
            if marker not in postscript:
                raise AssertionError(f"Installed td output lacks {marker!r}")


if __name__ == "__main__":
    main()
