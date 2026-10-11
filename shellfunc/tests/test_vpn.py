"""Run with: python3 -m unittest discover -s shellfunc/tests"""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


VPN = Path(__file__).resolve().parents[1] / ".local/bin/vpn"


class VpnTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        (self.root / "Downloads").mkdir()
        self.credentials = {
            "vpn": "dummy-vpn-password",
            "vpn-user": "test user",
            "vpn-url": "https://vpn.example.test/portal",
        }
        self.config = {"credentials": self.credentials}
        self.env = {
            **os.environ,
            "HOME": str(self.root),
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "VPN_TEST_ROOT": str(self.root),
            "VPN_TEST_PARENT_PID": str(os.getpid()),
            # An inherited export must not cause the new password to be exported.
            "password": "unrelated-inherited-value",
        }
        self.write_stub("pass", """
import json, os, pathlib, sys
config = json.loads((pathlib.Path(os.environ['VPN_TEST_ROOT']) / 'config.json').read_text())
key = sys.argv[1].rsplit('/', 1)[-1]
print(config['credentials'][key])
sys.exit(config.get('pass_failures', {}).get(key, 0))
""")
        self.write_stub("sudo", """
import json, os, pathlib, subprocess, sys
root = pathlib.Path(os.environ['VPN_TEST_ROOT'])
(root / 'sudo.json').write_text(json.dumps(sys.argv[1:]))
config = json.loads((root / 'config.json').read_text())
if config.get('sudo_exit_code', 0):
    sys.exit(config['sudo_exit_code'])
sys.exit(subprocess.call(sys.argv[1:]))
""")
        self.write_stub("openconnect", """
import json, os, pathlib, sys
root = pathlib.Path(os.environ['VPN_TEST_ROOT'])
record = {'argv': sys.argv[1:], 'stdin': sys.stdin.read(), 'processes': []}
if pathlib.Path('/proc/self/cmdline').exists():
    pid = os.getpid()
    while pid and pid != int(os.environ['VPN_TEST_PARENT_PID']):
        process = pathlib.Path('/proc') / str(pid)
        record['processes'].append({
            'argv': (process / 'cmdline').read_bytes().decode(errors='replace'),
            'env': (process / 'environ').read_bytes().decode(errors='replace'),
        })
        status = (process / 'status').read_text().splitlines()
        pid = int(next(line.split()[1] for line in status if line.startswith('PPid:')))
(root / 'openconnect.json').write_text(json.dumps(record))
print('VPN test connection finished')
sys.exit(json.loads((root / 'config.json').read_text()).get('openconnect_exit_code', 0))
""")
        self.write_stub("ts", """
import sys
sys.stdout.write(sys.stdin.read())
""")
        self.write_stub("expect", """
import sys
sys.exit('VPN authentication must not embed credentials in an Expect command')
""")

    def write_stub(self, name, source):
        stub = self.bin / name
        stub.write_text(f"#!{sys.executable}\n{source}")
        stub.chmod(0o755)

    def run_vpn(self):
        (self.root / "config.json").write_text(json.dumps(self.config))
        return subprocess.run(
            ["bash", "-x", str(VPN)],
            env=self.env,
            capture_output=True,
            text=True,
            timeout=10,
        )

    def test_password_only_reaches_openconnect_through_stdin(self):
        for password in (
            "dummy-vpn-password",
            " spaces [] {} $variable ; $(not-a-command) \\ \" ' café ",
        ):
            with self.subTest(password=password):
                self.credentials["vpn"] = password
                result = self.run_vpn()
                self.assertEqual(result.returncode, 0, result.stderr)
                record = json.loads((self.root / "openconnect.json").read_text())
                self.assertEqual(record["stdin"], password + "\n")
                self.assertEqual(record["argv"], [
                    "--usergroup=portal", "--protocol=gp", "--user=test user",
                    "--passwd-on-stdin", self.credentials["vpn-url"],
                ])
                sudo_argv = json.loads((self.root / "sudo.json").read_text())
                self.assertEqual(sudo_argv[0], str(self.bin / "openconnect"))
                self.assertNotIn(password, json.dumps(sudo_argv))
                for process in record["processes"]:
                    self.assertNotIn(password, process["argv"])
                    self.assertNotIn(password, process["env"])
                self.assertNotIn(password, result.stdout + result.stderr)
                log = (self.root / "Downloads/mksvpnlog.txt").read_text()
                self.assertNotIn(password, log)
                self.assertIn("Start time is ", log)
                self.assertIn("end time is ", log)

    def test_empty_credentials_prevent_connection(self):
        for key in self.credentials:
            with self.subTest(key=key):
                original = self.credentials[key]
                self.credentials[key] = ""
                result = self.run_vpn()
                self.credentials[key] = original
                self.assertEqual(result.returncode, 1)
                self.assertFalse((self.root / "sudo.json").exists())
                self.assertFalse((self.root / "openconnect.json").exists())

    def test_failed_credential_lookup_prevents_connection(self):
        for key in self.credentials:
            with self.subTest(key=key):
                # Even a lookup that prints partial output must be rejected.
                self.config["pass_failures"] = {key: 9}
                result = self.run_vpn()
                self.assertEqual(result.returncode, 1)
                self.assertFalse((self.root / "sudo.json").exists())
                self.assertFalse((self.root / "openconnect.json").exists())
                self.assertNotIn(self.credentials["vpn"], result.stdout + result.stderr)

    def test_connection_failure_is_not_hidden_by_logging(self):
        self.config["openconnect_exit_code"] = 23
        result = self.run_vpn()
        self.assertEqual(result.returncode, 23)
        self.assertIn("end time is ", result.stdout)

    def test_sudo_failure_prevents_connection(self):
        self.config["sudo_exit_code"] = 17
        result = self.run_vpn()
        self.assertEqual(result.returncode, 17)
        self.assertFalse((self.root / "openconnect.json").exists())


if __name__ == "__main__":
    unittest.main()
