"""Verify uninstall removes installed files but preserves unrelated files."""

import os

from common import arguments, installed_td, run_command


def main():
    args = arguments()
    with installed_td(args) as installation:
        installed_files = (installation.executable, installation.help_file)
        manifest_entries = {
            installation.stage / entry.lstrip("/")
            for entry in installation.manifest.read_text(encoding="utf-8").splitlines()
        }
        for path in installed_files:
            if not os.path.lexists(path):
                raise AssertionError(f"Expected installed file is missing: {path}")
            if path not in manifest_entries:
                raise AssertionError(f"Install manifest omits {path}")

        sentinel = installation.prefix / "unrelated-sentinel"
        sentinel.write_text("preserve me\n", encoding="utf-8")
        run_command(
            [
                installation.cmake,
                "--build",
                str(installation.build_dir),
                "--target",
                "uninstall",
            ],
            cwd=installation.work_dir,
            env=installation.env,
        )
        for path in installed_files:
            if os.path.lexists(path):
                raise AssertionError(f"Uninstall left {path} behind")
        if sentinel.read_text(encoding="utf-8") != "preserve me\n":
            raise AssertionError("Uninstall removed or changed an unrelated file")


if __name__ == "__main__":
    main()
