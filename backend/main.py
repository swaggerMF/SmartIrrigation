"""
Smart Irrigation AI Backend — FastAPI entry point.

Run:
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from ai_decision_service import SensorInput, make_irrigation_decision

app = FastAPI(
    title="Smart Irrigation AI Backend",
    description="Simulates an LLM irrigation decision service for ESP32-based systems.",
    version="1.0.0",
)

# Allow the Flutter app (any origin) to reach this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class SensorRequest(BaseModel):
    soil_moisture: float = Field(..., ge=0, le=100, example=35.0)
    temperature: float = Field(..., example=29.5)
    humidity: float = Field(..., ge=0, le=100, example=45.0)
    water_level: float = Field(..., ge=0, le=100, example=70.0)


class DecisionResponse(BaseModel):
    decision: str
    recommendation: str
    explanation: str


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/", tags=["health"])
def root():
    return {"status": "Smart Irrigation AI Backend is running"}


@app.post(
    "/ai/irrigation-decision",
    response_model=DecisionResponse,
    tags=["ai"],
    summary="Get an AI irrigation decision from current sensor values",
)
def irrigation_decision(request: SensorRequest) -> DecisionResponse:
    """
    Accepts the current sensor snapshot and returns:
    - **decision**: "ON" or "OFF"
    - **recommendation**: short human-readable summary
    - **explanation**: detailed reasoning

    The actual decision logic lives in `ai_decision_service.py`.
    Replace `make_irrigation_decision` there to plug in a real LLM.
    """
    try:
        sensor = SensorInput(
            soil_moisture=request.soil_moisture,
            temperature=request.temperature,
            humidity=request.humidity,
            water_level=request.water_level,
        )
        result = make_irrigation_decision(sensor)
        return DecisionResponse(
            decision=result.decision,
            recommendation=result.recommendation,
            explanation=result.explanation,
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
