from __future__ import annotations

from pathlib import Path
from typing import Callable

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "machinations_shapes"
SIZE = 256
SUPERSAMPLE = 4
CANVAS_SIZE = SIZE * SUPERSAMPLE
TRANSPARENT = (0, 0, 0, 0)
WHITE = (255, 255, 255, 255)
BLACK = (20, 24, 32, 255)
OUTLINE = 12 * SUPERSAMPLE
PADDING = 28 * SUPERSAMPLE


def to_px(x: float, y: float) -> tuple[float, float]:
    radius = (CANVAS_SIZE * 0.5) - PADDING
    center = CANVAS_SIZE * 0.5
    return center + x * radius, center + y * radius


def draw_closed_polygon(draw: ImageDraw.ImageDraw, points: list[tuple[float, float]], fill: tuple[int, int, int, int] = WHITE, outline: tuple[int, int, int, int] = BLACK, width: int = OUTLINE) -> None:
    pixel_points = [to_px(x, y) for x, y in points]
    draw.polygon(pixel_points, fill=fill)
    draw.line(pixel_points + [pixel_points[0]], fill=outline, width=width, joint="curve")


def draw_circle(draw: ImageDraw.ImageDraw, radius_scale: float = 0.8) -> None:
    center = CANVAS_SIZE * 0.5
    radius = ((CANVAS_SIZE * 0.5) - PADDING) * radius_scale
    draw.ellipse((center - radius, center - radius, center + radius, center + radius), fill=WHITE, outline=BLACK, width=OUTLINE)


def draw_square(draw: ImageDraw.ImageDraw, radius_scale: float = 0.7) -> None:
    center = CANVAS_SIZE * 0.5
    radius = ((CANVAS_SIZE * 0.5) - PADDING) * radius_scale
    draw.rectangle((center - radius, center - radius, center + radius, center + radius), fill=WHITE, outline=BLACK, width=OUTLINE)


def draw_pool(draw: ImageDraw.ImageDraw) -> None:
    draw_circle(draw, 0.82)


def draw_delay(draw: ImageDraw.ImageDraw) -> None:
    draw_circle(draw, 0.82)
    top_left = to_px(-0.22, -0.34)
    top_right = to_px(0.22, -0.34)
    bottom_left = to_px(-0.22, 0.34)
    bottom_right = to_px(0.22, 0.34)
    middle_top = to_px(0.0, -0.02)
    middle_bottom = to_px(0.0, 0.02)
    draw.line([top_left, top_right, middle_top, bottom_left, bottom_right], fill=BLACK, width=OUTLINE // 2, joint="curve")
    draw.line([top_left, middle_bottom, top_right], fill=BLACK, width=OUTLINE // 2, joint="curve")


def draw_source(draw: ImageDraw.ImageDraw) -> None:
    draw_closed_polygon(draw, [(-0.82, 0.54), (0.82, 0.54), (0.0, -0.82)])


def draw_drain(draw: ImageDraw.ImageDraw) -> None:
    draw_closed_polygon(draw, [(-0.82, -0.54), (0.82, -0.54), (0.0, 0.82)])


def draw_gate(draw: ImageDraw.ImageDraw) -> None:
    draw_closed_polygon(draw, [(0.0, -0.82), (0.82, 0.0), (0.0, 0.82), (-0.82, 0.0)])


def draw_converter(draw: ImageDraw.ImageDraw) -> None:
    draw_closed_polygon(draw, [(-0.48, 0.82), (-0.48, -0.82), (0.82, 0.0)])
    draw.line([to_px(0.0, -0.78), to_px(0.0, 0.78)], fill=BLACK, width=OUTLINE // 2)


def draw_trader(draw: ImageDraw.ImageDraw) -> None:
    draw_closed_polygon(draw, [(-0.74, -0.82), (0.62, -0.34), (-0.74, 0.14)])
    draw_closed_polygon(draw, [(-0.74, -0.14), (0.62, 0.34), (-0.74, 0.82)])
    draw.line([to_px(0.0, -0.9), to_px(0.0, 0.9)], fill=BLACK, width=OUTLINE // 2)


def draw_register(draw: ImageDraw.ImageDraw) -> None:
    draw_square(draw, 0.76)


def draw_endcondition(draw: ImageDraw.ImageDraw) -> None:
    draw_square(draw, 0.76)
    center = CANVAS_SIZE * 0.5
    radius = ((CANVAS_SIZE * 0.5) - PADDING) * 0.34
    draw.rectangle((center - radius, center - radius, center + radius, center + radius), fill=BLACK)


def draw_artificialplayer(draw: ImageDraw.ImageDraw) -> None:
    draw_square(draw, 0.8)
    font_path = ROOT / "assets" / "fonts" / "segoeui.ttf"
    font = ImageFont.truetype(str(font_path), 92 * SUPERSAMPLE)
    text = "AP"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    draw.text(((CANVAS_SIZE - text_w) * 0.5, (CANVAS_SIZE - text_h) * 0.5 - 18 * SUPERSAMPLE), text, fill=BLACK, font=font)


def draw_rect(draw: ImageDraw.ImageDraw) -> None:
    center = CANVAS_SIZE * 0.5
    half_w = ((CANVAS_SIZE * 0.5) - PADDING) * 0.95
    half_h = ((CANVAS_SIZE * 0.5) - PADDING) * 0.52
    draw.rounded_rectangle((center - half_w, center - half_h, center + half_w, center + half_h), radius=28 * SUPERSAMPLE, fill=WHITE, outline=BLACK, width=OUTLINE)


def draw_groupbox(draw: ImageDraw.ImageDraw) -> None:
    center = CANVAS_SIZE * 0.5
    half_w = ((CANVAS_SIZE * 0.5) - PADDING) * 0.95
    half_h = ((CANVAS_SIZE * 0.5) - PADDING) * 0.62
    x0 = center - half_w
    y0 = center - half_h
    x1 = center + half_w
    y1 = center + half_h
    dash = 42 * SUPERSAMPLE
    gap = 22 * SUPERSAMPLE
    x = x0
    while x < x1:
        draw.line([(x, y0), (min(x + dash, x1), y0)], fill=BLACK, width=OUTLINE // 2)
        draw.line([(x, y1), (min(x + dash, x1), y1)], fill=BLACK, width=OUTLINE // 2)
        x += dash + gap
    y = y0
    while y < y1:
        draw.line([(x0, y), (x0, min(y + dash, y1))], fill=BLACK, width=OUTLINE // 2)
        draw.line([(x1, y), (x1, min(y + dash, y1))], fill=BLACK, width=OUTLINE // 2)
        y += dash + gap


def draw_chart(draw: ImageDraw.ImageDraw) -> None:
    center = CANVAS_SIZE * 0.5
    half_w = ((CANVAS_SIZE * 0.5) - PADDING) * 0.92
    half_h = ((CANVAS_SIZE * 0.5) - PADDING) * 0.6
    draw.rounded_rectangle((center - half_w, center - half_h, center + half_w, center + half_h), radius=24 * SUPERSAMPLE, fill=WHITE, outline=BLACK, width=OUTLINE)
    base_y = center + half_h * 0.44
    left_x = center - half_w * 0.82
    right_x = center + half_w * 0.82
    draw.line([(left_x, base_y), (right_x, base_y)], fill=BLACK, width=OUTLINE // 3)
    points = [
        (left_x, base_y - 30 * SUPERSAMPLE),
        (center - 70 * SUPERSAMPLE, base_y - 86 * SUPERSAMPLE),
        (center - 12 * SUPERSAMPLE, base_y - 58 * SUPERSAMPLE),
        (center + 54 * SUPERSAMPLE, base_y - 128 * SUPERSAMPLE),
        (right_x, base_y - 104 * SUPERSAMPLE),
    ]
    draw.line(points, fill=BLACK, width=OUTLINE // 2, joint="curve")


def draw_textlabel(draw: ImageDraw.ImageDraw) -> None:
    del draw


def save_shape(name: str, painter: Callable[[ImageDraw.ImageDraw], None]) -> None:
    image = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), TRANSPARENT)
    draw = ImageDraw.Draw(image)
    painter(draw)
    final = image.resize((SIZE, SIZE), resample=Image.Resampling.LANCZOS)
    final.save(OUT_DIR / f"{name}.png")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    painters: dict[str, Callable[[ImageDraw.ImageDraw], None]] = {
        "pool": draw_pool,
        "delay": draw_delay,
        "source": draw_source,
        "drain": draw_drain,
        "gate": draw_gate,
        "converter": draw_converter,
        "trader": draw_trader,
        "register": draw_register,
        "endcondition": draw_endcondition,
        "artificialplayer": draw_artificialplayer,
        "rect": draw_rect,
        "groupbox": draw_groupbox,
        "chart": draw_chart,
        "textlabel": draw_textlabel,
    }
    for name, painter in painters.items():
        save_shape(name, painter)


if __name__ == "__main__":
    main()
