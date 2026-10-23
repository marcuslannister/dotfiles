"""Run with: kitty +runpy 'import runpy; runpy.run_path("tests/kitty-smart-paste.py")'"""

import runpy
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock


paste = runpy.run_path(str(Path(__file__).resolve().parents[1] / ".config/kitty/smart_paste.py"))["handle_result"]

for mime_types, image in (
    (("text/plain",), False),
    (("image/png",), True),
    (("image/tiff",), True),
    (("text/plain", "text/html", "image/png"), True),
    ((), False),
):
    window = Mock()
    boss = SimpleNamespace(
        window_id_map={1: window},
        clipboard=Mock(),
        paste_from_clipboard=Mock(),
    )
    boss.clipboard.get_available_mime_types_for_paste.return_value = mime_types
    paste([], None, 1, boss)
    if image:
        window.send_key.assert_called_once_with("alt+v")
        boss.paste_from_clipboard.assert_not_called()
    else:
        boss.paste_from_clipboard.assert_called_once_with()
        window.send_key.assert_not_called()

boss = SimpleNamespace(window_id_map={})
paste([], None, 1, boss)
print("PASS: text, PNG, TIFF, mixed formats, empty clipboard, and closed window")
