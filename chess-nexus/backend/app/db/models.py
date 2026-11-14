import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Boolean, Integer, Float, DateTime, ForeignKey, Text
)
from sqlalchemy.orm import relationship
from app.db.session import Base

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    username = Column(String(32), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=True)
    password_hash = Column(String(255), nullable=True)
    display_name = Column(String(64), nullable=False)
    avatar_id = Column(String(64), default="cyborg")
    locale = Column(String(8), default="en")
    is_verified = Column(Boolean, default=False)
    is_guest = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    ratings = relationship("Rating", back_populates="user", cascade="all, delete-orphan")
    white_matches = relationship("Match", foreign_keys="Match.white_player_id", back_populates="white_player")
    black_matches = relationship("Match", foreign_keys="Match.black_player_id", back_populates="black_player")

class Rating(Base):
    __tablename__ = "ratings"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    time_control_category = Column(String(16), nullable=False)  # bullet, blitz, rapid, classical, puzzle
    rating = Column(Float, default=1500.0, nullable=False)
    rating_deviation = Column(Float, default=350.0, nullable=False)
    volatility = Column(Float, default=0.06, nullable=False)
    games_played = Column(Integer, default=0, nullable=False)
    wins = Column(Integer, default=0, nullable=False)
    losses = Column(Integer, default=0, nullable=False)
    draws = Column(Integer, default=0, nullable=False)
    last_played_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="ratings")

class Match(Base):
    __tablename__ = "matches"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    white_player_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    black_player_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    time_control = Column(String(16), nullable=False)
    initial_time_seconds = Column(Integer, nullable=False)
    increment_seconds = Column(Integer, default=0, nullable=False)
    status = Column(String(24), default="in_progress")  # in_progress, completed, aborted, abandoned
    result = Column(String(16), nullable=True)  # 1-0, 0-1, 1/2-1/2
    termination_reason = Column(String(32), nullable=True)
    pgn = Column(Text, default="")
    final_fen = Column(String(128), default="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    white_rating_change = Column(Float, default=0.0)
    black_rating_change = Column(Float, default=0.0)
    tournament_id = Column(String(36), nullable=True)
    started_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    ended_at = Column(DateTime, nullable=True)

    white_player = relationship("User", foreign_keys=[white_player_id], back_populates="white_matches")
    black_player = relationship("User", foreign_keys=[black_player_id], back_populates="black_matches")

class Tournament(Base):
    __tablename__ = "tournaments"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(128), nullable=False)
    format = Column(String(32), default="swiss")  # swiss, arena, round_robin
    time_control = Column(String(16), default="blitz_3_2")
    total_rounds = Column(Integer, default=7)
    current_round = Column(Integer, default=1)
    status = Column(String(24), default="upcoming")  # upcoming, active, completed
    start_time = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    end_time = Column(DateTime, nullable=True)

class Puzzle(Base):
    __tablename__ = "puzzles"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    fen = Column(String(128), nullable=False)
    solution_moves = Column(Text, nullable=False)  # Space-separated UCI moves: e2e4 e7e5 ...
    rating = Column(Integer, default=1500)
    theme = Column(String(64), default="fork")
    description = Column(String(255), default="Find the winning tactical sequence")

