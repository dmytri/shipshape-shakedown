import json
import sys
from pathlib import Path

from behave import given, then, when

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from src.tide import next_high_tide


@given("the tide table for Fundy Cove")
def step_tide_table(context):
    data = Path(__file__).resolve().parents[2] / "data" / "tides.json"
    context.tides = json.loads(data.read_text())


@when('I ask for the next high tide after "{after}"')
def step_ask(context, after):
    context.result = None
    context.error = None
    try:
        context.result = next_high_tide(context.tides, after)
    except ValueError as exc:
        context.error = exc


@then('the predicted high tide is at "{time}" with height {height:f}')
def step_predicted(context, time, height):
    assert context.result["time"] == time, context.result
    assert context.result["height"] == height, context.result


@then('the prediction fails with "{message}"')
def step_failed(context, message):
    assert str(context.error) == message, context.error
