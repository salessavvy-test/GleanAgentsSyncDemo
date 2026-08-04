#!/usr/bin/env python3
"""
Utility module to add six numbers together.

This module exposes a single reusable function, `add_six_numbers`, which accepts
exactly six numeric values and returns their sum.
"""

from typing import Union

Number = Union[int, float]


def add_six_numbers(
    num1: Number,
    num2: Number,
    num3: Number,
    num4: Number,
    num5: Number,
    num6: Number
) -> Number:
    """Return the sum of six numeric values.

    Args:
        num1: The first number.
        num2: The second number.
        num3: The third number.
        num4: The fourth number.
        num5: The fifth number.
        num6: The sixth number.

    Returns:
        The sum of all six numbers.
    """
    return num1 + num2 + num3 + num4 + num5 + num6


if __name__ == "__main__":
    result = add_six_numbers(1, 2, 3, 4, 5, 6)
    print(f"The sum of 1 + 2 + 3 + 4 + 5 + 6 = {result}")
