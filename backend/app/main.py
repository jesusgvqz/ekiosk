from fastapi import FastAPI
from app.api.endpoints import router

app = FastAPI(title="ekiosk backend")

app.include_router(router)

@app.get("/")
def read_root():
    return {"message": "ekiosk backend running 🚀"}
