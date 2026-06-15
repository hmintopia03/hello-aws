from typing import Optional
import sqlite3

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()
DB_NAME = "data/users.db"


class UserCreate(BaseModel):
    name: str


class UserUpdate(BaseModel):
    name: str


class UserPatch(BaseModel):
    name: Optional[str] = None


def get_connection():
    return sqlite3.connect(DB_NAME)


def init_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()


init_db()


@app.get("/")
def root():
    return {"message": "hello aws postgres"}


@app.get("/users")
def get_users():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name FROM users")
    rows = cursor.fetchall()
    conn.close()

    return [{"id": row[0], "name": row[1]} for row in rows]


@app.post("/users")
def create_user(user: UserCreate):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO users (name) VALUES (?)", (user.name,))
    conn.commit()
    user_id = cursor.lastrowid
    conn.close()

    return {"id": user_id, "name": user.name}


@app.get("/users/{user_id}")
def get_user(user_id: int):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name FROM users WHERE id = ?", (user_id,))
    row = cursor.fetchone()
    conn.close()

    if row is None:
        raise HTTPException(status_code=404, detail="user not found")

    return {"id": row[0], "name": row[1]}


@app.put("/users/{user_id}")
def update_user(user_id: int, updated_user: UserUpdate):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE users SET name = ? WHERE id = ?",
        (updated_user.name, user_id)
    )
    conn.commit()

    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="user not found")

    conn.close()
    return {"id": user_id, "name": updated_user.name}


@app.patch("/users/{user_id}")
def patch_user(user_id: int, patch_data: UserPatch):
    if patch_data.name is None:
        return get_user(user_id)

    return update_user(user_id, UserUpdate(name=patch_data.name))


@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    user = get_user(user_id)

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
    conn.commit()
    conn.close()

    return {"message": "user deleted", "user": user}