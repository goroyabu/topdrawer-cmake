"""Exercise the installed help file through TD_HELP and the installed td."""

import errno
import os
import pty
import select
import subprocess
import time

from common import arguments, installed_td


def check_help(executable, help_file, work_dir, env):
    help_env = env.copy()
    help_env["TD_HELP"] = str(help_file)
    help_env["PAGER"] = "cat"
    master, slave = pty.openpty()
    process = None
    output = bytearray()
    sent_help = False
    sent_exit = False
    deadline = time.monotonic() + 15
    try:
        process = subprocess.Popen(
            [str(executable), "-d", "postscr"],
            cwd=work_dir,
            env=help_env,
            stdin=slave,
            stdout=slave,
            stderr=slave,
        )
        os.close(slave)
        slave = -1
        while time.monotonic() < deadline:
            if process.poll() is not None and not select.select([master], [], [], 0)[0]:
                break
            ready, _, _ = select.select([master], [], [], 0.1)
            if ready:
                try:
                    chunk = os.read(master, 4096)
                except OSError as error:
                    if error.errno == errno.EIO:
                        break
                    raise
                if not chunk:
                    break
                output.extend(chunk)
            if not sent_help and b"TD:" in output:
                os.write(master, b"HELP introduction\n")
                sent_help = True
            if sent_help and not sent_exit and b"TOPDRAWER is fairly easy" in output:
                os.write(master, b"\nEXIT\n")
                sent_exit = True
        else:
            raise AssertionError(
                f"Installed td help timed out:\n{output.decode(errors='replace')}"
            )
        if process.wait(timeout=1) != 0 or not sent_exit:
            raise AssertionError(
                f"Installed td help failed:\n{output.decode(errors='replace')}"
            )
        if b"Help file is not found" in output or b"Sorry, no help" in output:
            raise AssertionError(
                f"Installed td did not load help:\n{output.decode(errors='replace')}"
            )
    finally:
        if process is not None and process.poll() is None:
            process.kill()
            process.wait()
        if slave >= 0:
            os.close(slave)
        os.close(master)


def main():
    args = arguments()
    with installed_td(args) as installation:
        if not installation.executable.is_file():
            raise AssertionError(f"Installed td is missing: {installation.executable}")
        if not installation.help_file.is_file():
            raise AssertionError(f"Installed help file is missing: {installation.help_file}")
        check_help(
            installation.executable,
            installation.help_file,
            installation.work_dir,
            installation.env,
        )


if __name__ == "__main__":
    main()
