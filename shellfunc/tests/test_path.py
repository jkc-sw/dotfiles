"""Exercise PATH cleanup in Bash and Zsh without loading unrelated startup code."""

import os
from pathlib import Path
import shutil
import subprocess
import unittest


SHELLFUNC = Path(__file__).resolve().parents[1] / ".shellfunc"
CURRENT = "/nix/store/current-source/shellfunc/.local/bin"
OLD = "/nix/store/old-source/shellfunc/.local/bin"
OTHER = "/nix/store/old-source/tmux/.local/bin"


class PathTests(unittest.TestCase):
    def check_path(self, initial, directory, expected):
        # The helper precedes the color definitions and other shell setup.
        definition = SHELLFUNC.read_text().split("\nBOLD_TEXT=", 1)[0]
        for shell in ("bash", "zsh"):
            with self.subTest(shell=shell, initial=initial, directory=directory):
                executable = shutil.which(shell)
                self.assertIsNotNone(executable, f"{shell} is required")
                result = subprocess.run(
                    [executable, "-fc", definition + '\nPATH=$1; '
                     'addThisPath "$2"; addThisPath "$2"; printf "%s" "$PATH"',
                     "path-test", initial, directory],
                    env={**os.environ, "LC_ALL": "C"},
                    capture_output=True,
                    text=True,
                    timeout=5,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, expected)

    def test_stale_versions_are_removed_when_current_already_exists(self):
        for entries in (
            [OLD, CURRENT, OLD],
            [CURRENT, OLD, CURRENT],
            [OLD, OTHER, CURRENT, OLD],
        ):
            expected = [CURRENT, OTHER] if OTHER in entries else [CURRENT]
            self.check_path(
                ":".join(["/usr/bin", *entries, "/bin"]), CURRENT,
                ":".join(["/usr/bin", *expected, "/bin"]),
            )

    def test_replaces_old_version_at_its_original_position(self):
        self.check_path(
            f"/usr/bin:{OLD}:{OTHER}:/bin", CURRENT,
            f"/usr/bin:{CURRENT}:{OTHER}:/bin",
        )

    def test_plain_directory_duplicates_are_removed(self):
        self.check_path(
            "/usr/bin:/home/test/bin:/bin:/home/test/bin", "/home/test/bin",
            "/usr/bin:/home/test/bin:/bin",
        )

    def test_missing_directory_is_appended(self):
        self.check_path("/usr/bin:/bin", CURRENT, f"/usr/bin:/bin:{CURRENT}")

    def test_preserves_empty_entries_spaces_and_literal_characters(self):
        self.check_path(
            f":/tools with spaces/[literal]\\bin::{OLD}:{CURRENT}:", CURRENT,
            f":/tools with spaces/[literal]\\bin::{CURRENT}:",
        )

    def test_plain_directory_does_not_replace_a_similar_store_path(self):
        self.check_path(
            f"/usr/bin:{OLD}", "shellfunc/.local/bin",
            f"/usr/bin:{OLD}:shellfunc/.local/bin",
        )

    def test_empty_directory_leaves_path_unchanged(self):
        self.check_path("/usr/bin::/bin:", "", "/usr/bin::/bin:")


if __name__ == "__main__":
    unittest.main()
