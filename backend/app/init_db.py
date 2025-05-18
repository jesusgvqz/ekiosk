from app.core.database import Base, engine
from app.models.order_db import Order, Item

print("Creando tablas...")
Base.metadata.create_all(bind=engine)
print("Listo.")
