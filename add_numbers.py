#!/usr/bin/env python3
"""
Utility module to add numbers together.

This module exposes a function, `add_five_numbers`, which accepts exactly five
numeric values and returns their sum.
"""

from typing import Union

Number = Union[int, float]


def add_five_numbers(a: Number, b: Number, c: Number, d: Number, e: Number) -> Number:
    """Return the sum of five numbers.

    Args:
        a: First number
        b: Second number
        c: Third number
        d: Fourth number
        e: Fifth number

    Returns:
        The sum of all five input numbers.

    Example:
        >>> add_five_numbers(1, 2, 3, 4, 5)
        15
        >>> add_five_numbers(1.5, 2.5, 3.0, 4.0, 5.0)
        16.0
    """
    return a + b + c + d + e


def main():
    """Demonstrate adding five numbers together."""
    numbers = [10, 20, 30, 40, 50]
    result = add_five_numbers(*numbers)
    print(f"The sum of {numbers} is: {result}")


if __name__ == "__main__":
    main()
