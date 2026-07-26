"""Binds features/tides.feature to executable steps through pytest-bdd."""

import json
from pathlib import Path

import pytest
from pytest_bdd import given, parsers, scenarios, then, when

from src.tide import next_high_tide

scenarios("tides.feature")

DATA = Path(__file__).resolve().parents[1] / "data" / "tides.json"


@pytest.fixture
def context() -> dict:
    return {}


@given("the tide table for Fundy Cove")
def tide_table(context: dict) -> None:
    context["tides"] = json.loads(DATA.read_text())


@when(parsers.parse('I ask for the next high tide after "{after}"'))
def ask_next_high(context: dict, after: str) -> None:
    try:
        context["result"] = next_high_tide(context["tides"], after)
        context["error"] = None
    except ValueError as exc:
        context["result"] = None
        context["error"] = exc


@then(parsers.parse('the predicted high tide is at "{time}" with height {height:f}'))
def predicted(context: dict, time: str, height: float) -> None:
    assert context["result"]["time"] == time
    assert context["result"]["height"] == height


@then(parsers.parse('the prediction fails with "{message}"'))
def prediction_fails(context: dict, message: str) -> None:
    assert str(context["error"]) == message
