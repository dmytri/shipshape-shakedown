//! Tide prediction.

use serde::Deserialize;

/// One tide entry from a station's table.
#[derive(Debug, Clone, PartialEq, Deserialize)]
pub struct Tide {
    pub time: String,
    #[serde(rename = "type")]
    pub kind: String,
    pub height: f64,
}

/// Returns the first high tide after the given time.
///
/// # Errors
/// Returns an error when the table holds no later high tide.
pub fn next_high_tide(tides: &[Tide], after: &str) -> Result<Tide, String> {
    tides
        .iter()
        .find(|t| t.time.as_str() > after && t.kind == "high")
        .cloned()
        .ok_or_else(|| "no upcoming high tide in data".to_string())
}

/// Reads a station tide table from a JSON file.
///
/// # Errors
/// Returns an error when the file is missing or malformed.
pub fn load_tides(path: &str) -> Result<Vec<Tide>, String> {
    let raw = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
    serde_json::from_str(&raw).map_err(|e| e.to_string())
}
