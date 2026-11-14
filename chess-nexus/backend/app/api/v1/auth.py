from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.session import get_db
from app.db.models import User, Rating
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_token

router = APIRouter(prefix="/auth", tags=["Authentication"])

class RegisterRequest(BaseModel):
    username: str
    email: Optional[EmailStr] = None
    password: str
    display_name: Optional[str] = None

class LoginRequest(BaseModel):
    username_or_email: str
    password: str

class GuestLoginRequest(BaseModel):
    device_id: str
    nickname: Optional[str] = "Grandmaster"

class TokenResponse(BaseModel):
    user_id: str
    username: str
    display_name: str
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register_user(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    # Check if username exists
    res = await db.execute(select(User).where(User.username == req.username))
    if res.scalars().first():
        raise HTTPException(status_code=400, detail="Username already registered")

    user = User(
        username=req.username,
        email=req.email,
        password_hash=get_password_hash(req.password),
        display_name=req.display_name or req.username
    )
    db.add(user)
    await db.flush()

    # Create default ratings across all time categories
    for cat in ["bullet", "blitz", "rapid", "classical", "puzzle"]:
        rating = Rating(user_id=user.id, time_control_category=cat, rating=1500.0)
        db.add(rating)

    await db.commit()
    await db.refresh(user)

    return TokenResponse(
        user_id=user.id,
        username=user.username,
        display_name=user.display_name,
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id)
    )

@router.post("/login", response_model=TokenResponse)
async def login_user(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    res = await db.execute(
        select(User).where((User.username == req.username_or_email) | (User.email == req.username_or_email))
    )
    user = res.scalars().first()
    if not user or not user.password_hash or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    return TokenResponse(
        user_id=user.id,
        username=user.username,
        display_name=user.display_name,
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id)
    )

@router.post("/guest", response_model=TokenResponse)
async def guest_login(req: GuestLoginRequest, db: AsyncSession = Depends(get_db)):
    guest_username = f"guest_{req.device_id[:8]}"
    res = await db.execute(select(User).where(User.username == guest_username))
    user = res.scalars().first()
    if not user:
        user = User(
            username=guest_username,
            display_name=req.nickname or "Guest Grandmaster",
            is_guest=True
        )
        db.add(user)
        await db.flush()
        for cat in ["bullet", "blitz", "rapid", "classical", "puzzle"]:
            rating = Rating(user_id=user.id, time_control_category=cat, rating=1200.0)
            db.add(rating)
        await db.commit()
        await db.refresh(user)

    return TokenResponse(
        user_id=user.id,
        username=user.username,
        display_name=user.display_name,
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id)
    )

