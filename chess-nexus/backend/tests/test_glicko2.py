import pytest
from app.services.rating_service import Glicko2RatingSystem

def test_glicko2_win_increases_rating():
    rating, rd, vol = 1500.0, 200.0, 0.06
    opp_rating, opp_rd = 1500.0, 200.0
    new_r, new_rd, new_vol = Glicko2RatingSystem.calculate_rating_update(
        rating=rating,
        rd=rd,
        volatility=vol,
        opponent_rating=opp_rating,
        opponent_rd=opp_rd,
        score=1.0  # Win
    )
    assert new_r > rating
    assert new_rd < rd  # Deviation shrinks with more games

def test_glicko2_loss_decreases_rating():
    rating, rd, vol = 1500.0, 200.0, 0.06
    opp_rating, opp_rd = 1500.0, 200.0
    new_r, new_rd, new_vol = Glicko2RatingSystem.calculate_rating_update(
        rating=rating,
        rd=rd,
        volatility=vol,
        opponent_rating=opp_rating,
        opponent_rd=opp_rd,
        score=0.0  # Loss
    )
    assert new_r < rating
    assert new_rd < rd

def test_glicko2_upset_win():
    # Lower rated player beating higher rated player
    rating, rd, vol = 1400.0, 150.0, 0.06
    opp_rating, opp_rd = 1800.0, 80.0
    new_r, new_rd, _ = Glicko2RatingSystem.calculate_rating_update(
        rating=rating,
        rd=rd,
        volatility=vol,
        opponent_rating=opp_rating,
        opponent_rd=opp_rd,
        score=1.0
    )
    # Gaining significant points from an upset
    assert new_r - rating > 25.0

