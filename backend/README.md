# Smart Irrigation — AI Backend

FastAPI service that simulates an LLM irrigation decision module.

## Requirements
- Python 3.10+

## Setup and run

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate
# macOS / Linux
source venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at http://localhost:8000  
Interactive docs: http://localhost:8000/docs

## Endpoint

### POST /ai/irrigation-decision

**Request**
```json
{
  "soil_moisture": 35.0,
  "temperature": 29.5,
  "humidity": 45.0,
  "water_level": 70.0
}
```

**Response**
```json
{
  "decision": "ON",
  "recommendation": "Irrigation is recommended because soil moisture is below the optimal threshold.",
  "explanation": "Soil moisture is 35.0% (below 40%) and water level is 70.0% (sufficient). Starting the pump is safe."
}
```

## Decision rules (priority order)

| Condition | Decision |
|-----------|----------|
| water_level < 20 % | OFF (safety) |
| soil_moisture < 40 % AND water_level >= 20 % | ON |
| temperature > 32 °C AND soil_moisture < 45 % | ON |
| otherwise | OFF |

## Replacing simulated AI with a real LLM

Open `ai_decision_service.py` and replace the body of `make_irrigation_decision`
with an API call to your LLM provider. The docstring at the top of the file
contains a ready-to-use skeleton for the Claude API (`anthropic` package).

Steps:
1. `pip install anthropic`
2. Set your API key: `export ANTHROPIC_API_KEY=sk-ant-...`
3. Follow the skeleton in `ai_decision_service.py` to call `client.messages.create`
4. Parse the JSON response and return an `IrrigationDecision` object

The FastAPI route in `main.py` does not need to change.
