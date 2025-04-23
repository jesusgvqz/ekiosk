from fastapi import FastAPI
from app.api.endpoints import router

app = FastAPI(title="eKiosk Backend")

app.include_router(router)

@app.get("/")
def read_root():
    return {"message": "eKiosk backend running 🚀"}
