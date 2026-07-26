//! Executes `features/*.feature` through cucumber-rs.
use cucumber::{given, then, when, World};
use tidewatch::{load_tides, next_high_tide, Tide};

#[derive(Debug, Default, World)]
pub struct TideWorld {
    tides: Vec<Tide>,
    result: Option<Tide>,
    error: Option<String>,
}

#[given("the tide table for Fundy Cove")]
async fn tide_table(world: &mut TideWorld) {
    world.tides = load_tides("data/tides.json").expect("the tide table loads");
}

#[when(expr = "I ask for the next high tide after {string}")]
async fn ask_next_high(world: &mut TideWorld, after: String) {
    match next_high_tide(&world.tides, &after) {
        Ok(tide) => {
            world.result = Some(tide);
            world.error = None;
        }
        Err(message) => {
            world.result = None;
            world.error = Some(message);
        }
    }
}

#[then(expr = "the predicted high tide is at {string} with height {float}")]
async fn predicted(world: &mut TideWorld, time: String, height: f64) {
    let tide = world.result.as_ref().expect("a prediction");
    assert_eq!(tide.time, time);
    assert_eq!(tide.height, height);
}

#[then(expr = "the prediction fails with {string}")]
async fn prediction_fails(world: &mut TideWorld, message: String) {
    assert_eq!(world.error.as_deref(), Some(message.as_str()));
}

#[tokio::main]
async fn main() {
    TideWorld::cucumber()
        .fail_on_skipped()
        .run_and_exit("features")
        .await;
}
