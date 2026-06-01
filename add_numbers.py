#!/usr/bin/env python3
"""
Simple Python script to add two numbers.
"""

from typing import Union

Number = Union[int, float]


def add_two_numbers(a: Number, b: Number) -> Number:
    """
    Add two numbers and return the result.

    Args:
        a: First number.
        b: Second number.

    Returns:
        The sum of a and b.
    """
    return a + b


if __name__ == "__main__":
    # Example usage
    num1: Number = 5
    num2: Number = 3
    result = add_two_numbers(num1, num2)
    print(f"{num1} + {num2} = {result}")
