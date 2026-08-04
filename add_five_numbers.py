#!/usr/bin/env python3
"""
Program to add 5 numbers together.
Co-authored with Glean
"""

def add_five_numbers(num1, num2, num3, num4, num5):
    """Add five numbers and return the sum."""
    return num1 + num2 + num3 + num4 + num5


def main():
    print("Add Five Numbers Program")
    print("=" * 30)

    # Get 5 numbers from user
    numbers = []
    for i in range(1, 6):
        while True:
            try:
                num = float(input(f"Enter number {i}: "))
                numbers.append(num)
                break
            except ValueError:
                print("Invalid input. Please enter a valid number.")

    # Calculate sum
    total = add_five_numbers(*numbers)

    # Display result
    print(f"\nThe sum of {numbers[0]}, {numbers[1]}, {numbers[2]}, {numbers[3]}, and {numbers[4]} is: {total}")


if __name__ == "__main__":
    main()
