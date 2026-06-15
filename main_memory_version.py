from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()


class UserCreate(BaseModel):
    name: str


class UserUpdate(BaseModel):
    name: str


class UserPatch(BaseModel):
    name: Optional[str] = None


users = [
    {"id": 1, "name": "Alice"}
]


@app.get("/")
def root():
    return {"message": "hello aws"}


@app.get("/users")
def get_users():
    return users


@app.post("/users")
def create_user(user: UserCreate):
    new_user = {
        "id": len(users) + 1,
        "name": user.name
    }

    users.append(new_user)

    return new_user


@app.get("/users/{user_id}")
def get_user(user_id: int):
    for user in users:
        if user["id"] == user_id:
            return user

    raise HTTPException(
        status_code=404,
        detail="user not found"
    )


@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    for user in users:
        if user["id"] == user_id:
            users.remove(user)

            return {
                "message": "user deleted",
                "user": user
            }

    raise HTTPException(
        status_code=404,
        detail="user not found"
    )


@app.put("/users/{user_id}")
def update_user(user_id: int, updated_user: UserUpdate):
    for user in users:
        if user["id"] == user_id:
            user["name"] = updated_user.name
            return user

    raise HTTPException(
        status_code=404,
        detail="user not found"
    )


@app.patch("/users/{user_id}")
def patch_user(user_id: int, patch_data: UserPatch):
    for user in users:
        if user["id"] == user_id:

            if patch_data.name is not None:
                user["name"] = patch_data.name

            return user

    raise HTTPException(
        status_code=404,
        detail="user not found"
    )