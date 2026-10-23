from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    # Keep image paste aligned with Claude Code, Pi, and Herdr's remote bridge.
    if any(mime.startswith("image/") for mime in boss.clipboard.get_available_mime_types_for_paste()):
        window.send_key("alt+v")
    else:
        boss.paste_from_clipboard()
