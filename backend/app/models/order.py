from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class Item(BaseModel):
    product_id: str
    name: str
    quantity: int
    price: float

class Order(BaseModel):
    id: Optional[str] = None  # se asigna al guardar
    items: List[Item]
    total: float
    payment_method: str  # "cash" o "card"
    status: str = "pending"
    created_at: Optional[datetime] = None

class OrderStatusUpdate(BaseModel):
    status: str  # pending, preparing, ready, delivered

class PaymentMethod(BaseModel):
    payment_method: str  # "cash" o "card"
