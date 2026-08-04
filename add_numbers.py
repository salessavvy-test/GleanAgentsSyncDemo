#!/usr/bin/env python3
"""
Simple program to add 5 numbers together.
"""


def add_five_numbers(num1, num2, num3, num4, num5):
    """Add five numbers and return the sum."""
    return num1 + num2 + num3 + num4 + num5


def main():
    """Main function to demonstrate adding 5 numbers."""
    # Example: adding 5 numbers
    numbers = [10, 20, 30, 40, 50]
    result = add_five_numbers(*numbers)

    print(f"Adding the numbers: {numbers}")
    print(f"Result: {result}")

    # Interactive mode - uncomment to use
    # print("\nEnter 5 numbers to add:")
    # nums = []
    # for i in range(5):
    #     num = float(input(f"Number {i+1}: "))
    #     nums.append(num)
    # result = add_five_numbers(*nums)
    # print(f"\nSum of {nums} = {result}")


if __name__ == "__main__":
    main()
