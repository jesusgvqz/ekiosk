from fastapi import APIRouter

router = APIRouter()

@router.get("/orders")
def get_orders():
    return {"orders": []}

@router.post("/payment")
def process_payment():
    return {"status": "ok"}
