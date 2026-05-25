#!/usr/bin/env python3
"""
Simple Python script to add two numbers.
"""

def add_two_numbers(a, b):
    """
    Add two numbers and return the result.

    Args:
        a: First number
        b: Second number

    Returns:
        The sum of a and b
    """
    return a + b


if __name__ == "__main__":
    # Example usage
    num1 = 5
    num2 = 3
    result = add_two_numbers(num1, num2)
    print(f"{num1} + {num2} = {result}")
