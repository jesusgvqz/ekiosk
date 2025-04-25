from fastapi import APIRouter
from app.models.order import Order
from typing import List
from uuid import uuid4
from datetime import datetime
from fastapi import HTTPException
from fastapi import Path
from app.models.order import OrderStatusUpdate
from app.models.order import PaymentMethod
from fastapi import Body

router = APIRouter()

# Memoria temporal
orders_db: List[Order] = []

@router.post("/orders")
def create_order(order: Order):
    order.id = str(uuid4())
    order.created_at = datetime.now()
    orders_db.append(order)
    return {"message": "Orden creada", "order_id": order.id}

def get_orders():
    return {"orders": []}

@router.get("/orders/kitchen")
def get_kitchen_orders():
    kitchen_orders = [order for order in orders_db if order.status in ["pending", "preparing"]]
    if not kitchen_orders:
        raise HTTPException(status_code=404, detail="No hay órdenes activas")
    return kitchen_orders

@router.patch("/orders/{order_id}/status")
def update_order_status(order_id: str, status_update: OrderStatusUpdate):
    for order in orders_db:
        if order.id == order_id:
            order.status = status_update.status
            return {"message": f"Orden {order_id} actualizada a '{order.status}'"}
    raise HTTPException(status_code=404, detail="Orden no encontrada")

@router.post("/orders/{order_id}/pay")
def register_payment_method(order_id: str, payment: PaymentMethod):
    for order in orders_db:
        if order.id == order_id:
            order.payment_method = payment.payment_method
            order.status = "waiting_payment"

            if payment.payment_method == "cash":
                return {"message": "Orden enviada a caja", "next_step": "cashier"}
            elif payment.payment_method == "card":
                return {"message": "Orden enviada a terminal bancaria", "next_step": "terminal"}
            else:
                raise HTTPException(status_code=400, detail="Método de pago inválido")

    raise HTTPException(status_code=404, detail="Orden no encontrada")

@router.post("/cashier/pay")
def pay_at_cashier(order_id: str = Body(..., embed=True)):
    for order in orders_db:
        if order.id == order_id:
            order.status = "paid"
            return {"message": f"Orden {order.id} pagada en caja"}
    raise HTTPException(status_code=404, detail="Orden no encontrada")

@router.post("/terminal/pay")
def pay_with_terminal(order_id: str = Body(..., embed=True)):
    for order in orders_db:
        if order.id == order_id:
            order.status = "paid"
            return {"message": f"Orden {order.id} pagada en terminal bancaria"}
    raise HTTPException(status_code=404, detail="Orden no encontrada")

@router.post("/payment")
def process_payment():
    return {"status": "ok"}


# tmp menu
@router.get("/menu")
def get_menu():
    return [
        {"product_id": "001", "name": "Burrito de arrachera", "price": 85},
        {"product_id": "002", "name": "Quesadilla", "price": 45},
        {"product_id": "003", "name": "Refresco", "price": 25},
    ]
