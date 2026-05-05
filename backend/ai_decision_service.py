"""
AI/LLM Decision Service

This module contains the core irrigation decision logic.
Currently it uses rule-based simulation.

To replace with a real LLM (e.g. Claude, GPT-4):
  1. Install the SDK:  pip install anthropic   (or openai)
  2. Replace the body of `make_irrigation_decision` with an API call.
  3. Parse the LLM response and return an IrrigationDecision.

Example skeleton for Claude API:
    import anthropic
    client = anthropic.Anthropic(api_key="YOUR_KEY")

    def make_irrigation_decision(sensor: SensorInput) -> IrrigationDecision:
        prompt = (
            f"Soil moisture: {sensor.soil_moisture}%\\n"
            f"Temperature: {sensor.temperature}°C\\n"
            f"Air humidity: {sensor.humidity}%\\n"
            f"Water level: {sensor.water_level}%\\n"
            "Should the irrigation pump be turned ON or OFF? "
            "Reply with JSON: {decision, recommendation, explanation}"
        )
        message = client.messages.create(
            model="claude-opus-4-7",
            max_tokens=256,
            messages=[{"role": "user", "content": prompt}],
        )
        data = json.loads(message.content[0].text)
        return IrrigationDecision(**data)
"""

from dataclasses import dataclass


@dataclass
class SensorInput:
    soil_moisture: float
    temperature: float
    humidity: float
    water_level: float


@dataclass
class IrrigationDecision:
    decision: str          # "ON" or "OFF"
    recommendation: str
    explanation: str


def make_irrigation_decision(sensor: SensorInput) -> IrrigationDecision:
    """
    Evaluate sensor data and return an irrigation decision.
    Rules are evaluated in priority order — first match wins.
    """
    soil = sensor.soil_moisture
    temp = sensor.temperature
    water = sensor.water_level

    # Safety rule: never irrigate when reservoir is critically low
    if water < 20:
        return IrrigationDecision(
            decision="OFF",
            recommendation=(
                "Irrigation is not recommended. "
                "The water reservoir level is critically low."
            ),
            explanation=(
                f"Water level is {water:.1f}%, which is below the 20% safety threshold. "
                "Refill the reservoir before running the pump."
            ),
        )

    # Dry soil with sufficient water
    if soil < 40 and water >= 20:
        return IrrigationDecision(
            decision="ON",
            recommendation=(
                "Irrigation is recommended because soil moisture is below the optimal threshold."
            ),
            explanation=(
                f"Soil moisture is {soil:.1f}% (below 40%) and water level is {water:.1f}% "
                "(sufficient). Starting the pump is safe."
            ),
        )

    # High temperature with moderately dry soil — heat stress risk
    if temp > 32 and soil < 45:
        return IrrigationDecision(
            decision="ON",
            recommendation=(
                "Irrigation is recommended due to high temperature and moderately dry soil."
            ),
            explanation=(
                f"Temperature is {temp:.1f}°C (above 32°C) and soil moisture is {soil:.1f}% "
                f"(below 45%). Heat stress on plants is elevated."
            ),
        )

    # Default: conditions are fine
    return IrrigationDecision(
        decision="OFF",
        recommendation=(
            "Irrigation is not currently needed. Soil and water conditions are adequate."
        ),
        explanation=(
            f"Soil moisture is {soil:.1f}%, temperature is {temp:.1f}°C, "
            f"and water level is {water:.1f}%. All values are within the normal range."
        ),
    )
