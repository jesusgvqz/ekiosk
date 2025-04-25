# Start Uvicorn
```powershell
uvicorn app.main:app --reload --port 8000
```
---
# Example

```json
{
  "items": [
    {
      "product_id": "001",
      "name": "Burrito de arrachera",
      "quantity": 2,
      "price": 85
    },
    {
      "product_id": "002",
      "name": "Refresco",
      "quantity": 1,
      "price": 25
    }
  ],
  "total": 195,
  "payment_method": "cash"
}

```