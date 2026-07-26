"""Tide prediction."""

from datetime import datetime


def _parse(stamp: str) -> datetime:
    return datetime.fromisoformat(stamp)


def next_high_tide(tides: list[dict], after: str) -> dict:
    """Return the first high tide after the given time."""
    for tide in tides:
        if _parse(tide["time"]) > _parse(after) and tide["type"] == "high":
            return tide
    raise ValueError("no upcoming high tide in data")
