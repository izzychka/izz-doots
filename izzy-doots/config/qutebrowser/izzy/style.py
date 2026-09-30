from pathlib import Path
import subprocess
_base = Path(config.configdir) / 'izzy'
_fonts = ['Maple Mono', 'Maple Mono NF', 'Maple Mono NF CN', 'monospace']
c.fonts.default_family = _fonts
c.fonts.default_size = '10pt'
c.tabs.show = 'switching'
c.tabs.show_switching_delay = 1300
c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 10, 'right': 10}
c.tabs.indicator.width = 0
c.tabs.favicons.show = 'never'
c.statusbar.show = 'in-mode'
c.statusbar.padding = {'top': 4, 'bottom': 4, 'left': 8, 'right': 8}
c.colors.webpage.darkmode.enabled = False
c.colors.webpage.preferred_color_scheme = 'dark'
c.url.start_pages = [(_base / 'home/index.html').as_uri()]
c.url.default_page = (_base / 'home/index.html').as_uri()
c.url.searchengines = {'DEFAULT': 'https://www.google.com/search?q={}'}
config.source(str(_base / 'theme.py'))
config.bind(',h', 'home')
config.bind(',b', 'config-cycle tabs.show always switching')
config.bind(',s', 'config-cycle statusbar.show always in-mode')
config.bind(',d', 'jseval -q window.__izzyDarkReader && window.__izzyDarkReader.toggle()')
