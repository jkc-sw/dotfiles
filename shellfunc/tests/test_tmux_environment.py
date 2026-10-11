"""Check client PATH refresh on an isolated tmux server."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


TMUX_CONFIG = Path(__file__).resolve().parents[2] / "tmux/.tmux.conf"


class TmuxEnvironmentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tmux-path-test-")
        self.addCleanup(self.temp.cleanup)
        self.socket = str(Path(self.temp.name) / "socket")
        self.tmux = shutil.which("tmux")
        self.assertIsNotNone(self.tmux, "tmux is required")
        self.old_env = {**os.environ, "PATH": "/old-tools:/usr/bin:/bin"}
        self.new_env = {**os.environ, "PATH": "/new-tools:/usr/bin:/bin"}
        self.old_env.pop("TMUX", None)
        self.new_env.pop("TMUX", None)
        self.addCleanup(self.stop_server)
        subprocess.run(
            [self.tmux, "-S", self.socket, "-f", str(TMUX_CONFIG),
             "new-session", "-d", "-s", "existing", "/bin/sleep 60"],
            env=self.old_env,
            capture_output=True,
            text=True,
            check=True,
            timeout=5,
        )

    def stop_server(self):
        # Only the server on this test's private socket is stopped.
        subprocess.run(
            [self.tmux, "-S", self.socket, "kill-server"],
            capture_output=True,
            timeout=5,
        )

    def session_path(self, name):
        return subprocess.check_output(
            [self.tmux, "-S", self.socket, "show-environment", "-t", name, "PATH"],
            text=True,
            timeout=5,
        ).strip()

    def test_new_session_receives_client_path(self):
        subprocess.run(
            [self.tmux, "-S", self.socket, "new-session", "-d", "-s", "new",
             "/bin/sleep 60"],
            env=self.new_env,
            capture_output=True,
            check=True,
            timeout=5,
        )
        self.assertEqual(self.session_path("new"), "PATH=" + self.new_env["PATH"])

    def test_reattach_refreshes_path_and_preserves_running_pane(self):
        pane_before = subprocess.check_output(
            [self.tmux, "-S", self.socket, "display-message", "-p", "-t", "existing",
             "#{pane_pid}"],
            text=True,
            timeout=5,
        )
        subprocess.run(
            [self.tmux, "-S", self.socket, "-C", "attach-session", "-t", "existing"],
            env=self.new_env,
            input="detach-client\n",
            capture_output=True,
            text=True,
            check=True,
            timeout=5,
        )
        self.assertEqual(self.session_path("existing"), "PATH=" + self.new_env["PATH"])
        pane_after = subprocess.check_output(
            [self.tmux, "-S", self.socket, "display-message", "-p", "-t", "existing",
             "#{pane_pid}"],
            text=True,
            timeout=5,
        )
        self.assertEqual(pane_before, pane_after)


if __name__ == "__main__":
    unittest.main()
