import math

"""
Produce progress bar with ANSI code output.
https://mike42.me/blog/2018-06-make-better-cli-progress-bars-with-unicode-block-characters
"""
def progress_bar_str(progress : float, width : int, begin_symbol = None, end_symbol = None):
    # 0 <= progress <= 1
    progress = min(1, max(0, progress))
    whole_width = math.floor(progress * width)
    remainder_width = (progress * width) % 1
    part_width = math.floor(remainder_width * 8)
    #part_char = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉"][part_width]
    part_char = "▱" if remainder_width < 0.5 else "▰"
    if (width - whole_width - 1) < 0:
      part_char = ""
    #line = "[" + "█" * whole_width + part_char + " " * (width - whole_width - 1) + "]"
    #line = "█" * whole_width + part_char + " " * (width - whole_width - 1)
    line = "▰" * whole_width + part_char + "▱" * (width - whole_width - 1)
    if begin_symbol is not None:
        line = begin_symbol + line
    if end_symbol is not None:
        line += end_symbol
    return line

