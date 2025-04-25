from fastapi import FastAPI
from app.api.endpoints import router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="ekiosk backend")

app.include_router(router)

@app.get("/")
def read_root():
    return {"message": "ekiosk backend running 🚀"}


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # O ["http://localhost:53031"] si quieres especificar
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
