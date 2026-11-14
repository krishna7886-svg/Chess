import math
from typing import Tuple

class Glicko2RatingSystem:
    """
    Standard Glicko-2 Rating Algorithm Implementation.
    Ref: Mark E. Glickman, 'Example of the Glicko-2 system'.
    """

    SCALE = 173.7178
    DEFAULT_TAU = 0.5  # System constant constraining volatility change
    EPSILON = 0.000001

    @classmethod
    def _g(cls, phi: float) -> float:
        return 1.0 / math.sqrt(1.0 + 3.0 * (phi ** 2) / (math.pi ** 2))

    @classmethod
    def _E(cls, mu: float, mu_j: float, phi_j: float) -> float:
        return 1.0 / (1.0 + math.exp(-cls._g(phi_j) * (mu - mu_j)))

    @classmethod
    def calculate_rating_update(
        cls,
        rating: float,
        rd: float,
        volatility: float,
        opponent_rating: float,
        opponent_rd: float,
        score: float,  # 1.0 for win, 0.5 for draw, 0.0 for loss
        tau: float = DEFAULT_TAU
    ) -> Tuple[float, float, float]:
        """
        Calculates updated (new_rating, new_rd, new_volatility) for a single match.
        """
        # Step 2: Convert to Glicko-2 scale
        mu = (rating - 1500.0) / cls.SCALE
        phi = rd / cls.SCALE
        sigma = volatility

        mu_j = (opponent_rating - 1500.0) / cls.SCALE
        phi_j = opponent_rd / cls.SCALE

        # Step 3: Compute variance v
        g_phi_j = cls._g(phi_j)
        e_val = cls._E(mu, mu_j, phi_j)
        v = 1.0 / ((g_phi_j ** 2) * e_val * (1.0 - e_val))

        # Step 4: Compute delta
        delta = v * g_phi_j * (score - e_val)

        # Step 5: Determine new volatility sigma' using Illinois/Newton-Raphson method
        a = math.log(sigma ** 2)

        def f(x: float) -> float:
            exp_x = math.exp(x)
            d2 = delta ** 2
            p2 = phi ** 2
            term1 = (exp_x * (d2 - p2 - v - exp_x)) / (2.0 * ((p2 + v + exp_x) ** 2))
            term2 = (x - a) / (tau ** 2)
            return term1 - term2

        # Bracket search
        A = a
        if (delta ** 2) > (phi ** 2 + v):
            B = math.log(delta ** 2 - phi ** 2 - v)
        else:
            k = 1
            while f(a - k * tau) < 0:
                k += 1
            B = a - k * tau

        f_A = f(A)
        f_B = f(B)

        while abs(B - A) > cls.EPSILON:
            C = A + (A - B) * f_A / (f_B - f_A)
            f_C = f(C)
            if (f_C * f_B) <= 0:
                A = B
                f_A = f_B
            else:
                f_A = f_A / 2.0
            B = C
            f_B = f_C

        new_sigma = math.exp(A / 2.0)

        # Step 6: Update rating deviation to new pre-rating period value
        phi_star = math.sqrt(phi ** 2 + new_sigma ** 2)

        # Step 7: Update rating and RD to new values
        new_phi = 1.0 / math.sqrt(1.0 / (phi_star ** 2) + 1.0 / v)
        new_mu = mu + (new_phi ** 2) * g_phi_j * (score - e_val)

        # Step 8: Convert back to original Glicko/Elo scale
        final_rating = cls.SCALE * new_mu + 1500.0
        final_rd = cls.SCALE * new_phi

        # Guardrails: minimum RD 30 (high confidence), maximum RD 350 (unrated)
        final_rd = max(30.0, min(350.0, final_rd))
        final_rating = max(100.0, final_rating)

        return round(final_rating, 1), round(final_rd, 1), round(new_sigma, 6)

