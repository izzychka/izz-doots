"""Offline integration checks; never writes to the real user's home."""
import argparse
import importlib.util
from importlib.machinery import SourceFileLoader
import json
from pathlib import Path
import tempfile
import tomllib
import unittest
import install

spec = importlib.util.spec_from_loader('theme', SourceFileLoader('theme', str(install.SOURCE / 'scripts/izzy-theme')))
theme = importlib.util.module_from_spec(spec)
spec.loader.exec_module(theme)


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.base = Path(self.temp.name)
        self.home = self.base / 'home'
        self.stage = self.base / 'stage'
        self.home.mkdir(); self.stage.mkdir()
        self.old_home = install.HOME
        install.HOME = self.home
        self.args = argparse.Namespace(surface_monitor=False)
        install.build(self.stage, self.args)

    def tearDown(self):
        install.HOME = self.old_home
        self.temp.cleanup()

    def test_portable_paths_and_exclusions(self):
        self.assertFalse((self.stage / '.config/vesktop/sessionData').exists())
        self.assertFalse((self.stage / '.config/spotify/prefs').exists())
        self.assertFalse((self.stage / '.local/bin/pywalfox').exists())
        for p in self.stage.rglob('*'):
            if p.is_file():
                try: text = p.read_text()
                except UnicodeError: continue
                self.assertNotIn('/home/surfarch', text, str(p))
                self.assertNotIn('/home/izzy/', text, str(p))
        for folder in ['type4', 'type-4']:
            self.assertTrue((self.stage / f'.config/rofi/launchers/{folder}/launcher.sh').stat().st_mode & 0o111)

    def test_every_preset_renders_every_template(self):
        config = tomllib.loads((self.stage / '.config/matugen/config.toml').read_text())
        for palette_path in (self.stage / '.config/izzy-themes').glob('*.json'):
            palette = json.loads(palette_path.read_text())
            for name, entry in config['templates'].items():
                path = Path(entry['input_path'].replace('~', str(self.home), 1)).relative_to(self.home)
                rendered = theme.render((self.stage / path).read_text(), palette, self.home / 'wallpaper.png')
                self.assertNotIn('{{', rendered, name)
                if Path(entry['output_path']).suffix == '.json':
                    json.loads(rendered)

    def test_backup_and_install(self):
        old = self.home / '.config/kitty'
        old.mkdir(parents=True)
        (old / 'keep-me').write_text('original')
        install.install_files(self.stage)
        backups = list((self.home / '.local/state/izzy-rice/backups').iterdir())
        self.assertEqual((backups[0] / '.config/kitty/keep-me').read_text(), 'original')
        self.assertTrue((self.home / '.config/kitty/kitty.conf').is_file())
        self.assertTrue((backups[0] / 'manifest.json').is_file())

    def test_refresh_generates_lock_and_export(self):
        spec = importlib.util.spec_from_file_location('refresh', Path(__file__).with_name('refresh.py'))
        refresh = importlib.util.module_from_spec(spec); spec.loader.exec_module(refresh)
        refresh.HOME = self.home
        refresh.PALETTE = self.home / '.config/matugen/generated/izzy-pixie.palette'
        refresh.EXPORT = self.home / '.local/share/izzy-pixie/export'
        install.copy_tree(self.stage / '.config', self.home / '.config')
        image = self.home / 'wallpaper.png'
        refresh.Image.new('RGB', (10, 10), 'purple').save(image)
        keys = {key: '#123456' for key in refresh.KEYS}
        refresh.PALETTE.parent.mkdir(parents=True, exist_ok=True)
        refresh.PALETTE.write_text('\n'.join(k+'='+v for k,v in keys.items()) + '\nimage='+str(image))
        refresh.refresh()
        lock = (self.home / '.config/hypr/izzy-lock.conf').read_text()
        self.assertIn('rgb(18, 52, 86)', lock)
        self.assertIn(str(refresh.EXPORT / 'background.png'), lock)
        self.assertTrue((refresh.EXPORT / 'ready').exists())
        refresh.PALETTE.write_text(refresh.PALETTE.read_text().replace('#123456', 'invalid', 1))
        with self.assertRaises(ValueError): refresh.refresh()

if __name__ == '__main__': unittest.main()
