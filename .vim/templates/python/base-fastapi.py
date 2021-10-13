from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    name: str
    price: float
    is_offer: bool = None


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):  # like /items/2?q=foo
    return {"item_id": item_id, "q": q}


@app.post("items/{item_id}")
def post_item(item_id: int, item: Item):  # with responce body
    return {"item_name": item.name, "item_id": item_id}
