#!/usr/bin/env python3
import time

BASE = 0x1CE50  # sextants base (2x3), mask 0..63 → U+1CE50+mask

# ------- sextant helpers -------
def sextant_char(tl,tr, ml,mr, bl,br):
    mask = (tl&1)|((tr&1)<<1)|((ml&1)<<2)|((mr&1)<<3)|((bl&1)<<4)|((br&1)<<5)
    return " " if mask == 0 else chr(BASE + mask)

def lr_fill(idx, base):
    return (1 if idx > base else 0, 1 if idx > base+1 else 0)

def hour_to_idx(h,m,s):  # 0..59, one step per 12 min
    return (h % 12)*5 + (m // 12)

def build_cells(t_idx, m_idx, b_idx, cells=30):
    out = []
    for i in range(cells):
        b = i*2
        tL,tR = lr_fill(t_idx, b)
        mL,mR = lr_fill(m_idx, b)
        bL,bR = lr_fill(b_idx, b)
        out.append(sextant_char(tL,tR, mL,mR, bL,bR))
    return out

# ------- separators -------
def line_with_dividers(
    cells,
    n=6,
    left_cap="⟨",
    right_cap="⟩",
    mid_sep="│",
    other_sep="╵",
    include_edges=True,
):
    L = len(cells)
    if L == 0:
        return left_cap + right_cap if include_edges else ""

    # cut points: 0, floor(L/n), ..., L
    cuts = [0] + [(k*L)//n for k in range(1, n)] + [L]

    parts = []
    if include_edges:
        parts.append(left_cap)

    # insert a sep between segments, full at center cut, half elsewhere
    mid_cut = L // 2
    for k in range(len(cuts)-1):
        a, b = cuts[k], cuts[k+1]
        parts.append("".join(cells[a:b]))
        if k < len(cuts)-2:
            cut_pos = cuts[k+1]
            parts.append(mid_sep if cut_pos == mid_cut else other_sep)

    if include_edges:
        parts.append(right_cap)
    return "".join(parts)

# ------- main -------
if __name__ == "__main__":
    CELLS = 30
    DIVS  = 6                    # bars at every len/6 → every 5 cells → 10s
    LEFT_CAP  = "│"#"⟨"
    RIGHT_CAP = "│"#"⟩"
    MID_SEP   = "│"              # full height at center (30s)
    OTHER_SEP = "╵"              # half height at 10,20,40,50s

    while True:
        t = time.localtime()
        h,m,s = t.tm_hour, t.tm_min, t.tm_sec
        cells = build_cells(s, m, hour_to_idx(h,m,s), cells=CELLS)
        line  = line_with_dividers(
            cells, n=DIVS,
            left_cap=LEFT_CAP, right_cap=RIGHT_CAP,
            mid_sep=MID_SEP, other_sep=OTHER_SEP,
            include_edges=True
        )
        print("\r" + line, end="", flush=True)
        time.sleep(1)
