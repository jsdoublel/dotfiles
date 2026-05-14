from typing import Dict, Any
from kitty.boss import Boss
from kitty.window import Window
from kitty.fast_data_types import viewport_for_window


def layout_name(short_layout: str) -> str:
    return f"{short_layout}:bias=50;full_size=1;mirrored=false"


def on_resize(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    if boss.active_tab is None:
        return
    try:
        _, _, width, height, _, _ = viewport_for_window(window.os_window_id)
    except Exception:
        return
    new_layout = layout_name("tall") if width >= height else layout_name("fat")
    if new_layout not in boss.active_tab.enabled_layouts:
        cur_layout = boss.active_tab.current_layout.name
        boss.active_tab.set_enabled_layouts([new_layout, "stack"])
        if cur_layout != "stack":
            boss.active_tab.goto_layout(new_layout)
