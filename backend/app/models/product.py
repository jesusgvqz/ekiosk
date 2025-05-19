from pydantic import BaseModel

class ProductCreate(BaseModel):
    product_id: str
    name: str
    price: float
