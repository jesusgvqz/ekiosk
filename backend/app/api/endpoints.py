from fastapi import APIRouter
from typing import List
from uuid import uuid4
from datetime import datetime
from fastapi import HTTPException
from fastapi import Path
from fastapi import Body
from fastapi import Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from uuid import uuid4
from datetime import datetime

from app.models.order import Order
from app.models.order import OrderStatusUpdate
from app.models.order import PaymentMethod
from app.models.order_db import Order as DBOrder, Item as DBItem
from app.models.order import Order as RequestOrder  # Pydantic model
from app.models.product_db import Product as DBProduct
from app.models.product import ProductCreate

router = APIRouter()

@router.post("/menu")
def add_product(product: ProductCreate, db: Session = Depends(get_db)):
    new_product = DBProduct(
        product_id=product.product_id,
        name=product.name,
        price=product.price,
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return {"message": "Producto agregado", "id": new_product.id}

@router.get("/menu")
def get_menu(db: Session = Depends(get_db)):
    products = db.query(DBProduct).all()
    return [
        {"product_id": p.product_id, "name": p.name, "price": p.price}
        for p in products
    ]


@router.post("/orders")
def create_order(order: RequestOrder, db: Session = Depends(get_db)):
    order_id = str(uuid4())
    db_order = DBOrder(
        id=order_id,
        total=order.total,
        payment_method=order.payment_method,
        status="pending",
        created_at=datetime.utcnow(),
    )

    for item in order.items:
        db_item = DBItem(
            product_id=item.product_id,
            name=item.name,
            quantity=item.quantity,
            price=item.price,
            order=db_order,
        )
        db_order.items.append(db_item)

    db.add(db_order)
    db.commit()
    db.refresh(db_order)

    return {"message": "Orden creada", "order_id": db_order.id}

def get_orders():
    return {"orders": []}

@router.get("/orders/kitchen")
def get_kitchen_orders(db: Session = Depends(get_db)):
    kitchen_orders = db.query(DBOrder).filter(DBOrder.status.in_(["pending", "preparing"])).all()
    return [
        {
            "order_id": order.id,
            "status": order.status,
            "created_at": order.created_at.isoformat(),
            "items": [
                {
                    "name": item.name,
                    "quantity": item.quantity,
                    "price": item.price
                } for item in order.items
            ]
        } for order in kitchen_orders
    ]


@router.patch("/orders/{order_id}/status")
def update_order_status(order_id: str, status_update: OrderStatusUpdate):
    for order in orders_db:
        if order.id == order_id:
            order.status = status_update.status
            return {"message": f"Orden {order_id} actualizada a '{order.status}'"}
    raise HTTPException(status_code=404, detail="Orden no encontrada")

@router.patch("/orders/{order_id}/status")
def update_order_status(order_id: str, status_update: OrderStatusUpdate, db: Session = Depends(get_db)):
    order = db.query(DBOrder).filter(DBOrder.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Orden no encontrada")

    order.status = status_update.status
    db.commit()
    db.refresh(order)
    return {"message": f"Orden {order_id} actualizada a '{order.status}'"}


@router.post("/cashier/pay")
def pay_at_cashier(order_id: str = Body(..., embed=True), db: Session = Depends(get_db)):
    order = db.query(DBOrder).filter(DBOrder.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Orden no encontrada")
    order.status = "pending"
    db.commit()
    return {"message": f"Orden {order.id} pagada en caja"}


@router.post("/terminal/pay")
def pay_with_terminal(order_id: str = Body(..., embed=True), db: Session = Depends(get_db)):
    order = db.query(DBOrder).filter(DBOrder.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Orden no encontrada")
    order.status = "pending"
    db.commit()
    return {"message": f"Orden {order.id} pagada en terminal bancaria"}


@router.delete("/menu/{product_id}")
def delete_product(product_id: str, db: Session = Depends(get_db)):
    product = db.query(DBProduct).filter(DBProduct.product_id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    db.delete(product)
    db.commit()
    return {"message": f"Producto {product_id} eliminado"}


@router.post("/payment")
def process_payment():
    return {"status": "ok"}

