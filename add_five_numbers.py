def add_five_numbers(num1, num2, num3, num4, num5):
    """
    Add five numbers together and return the sum.

    Args:
        num1, num2, num3, num4, num5: Numbers to add

    Returns:
        The sum of all five numbers
    """
    return num1 + num2 + num3 + num4 + num5


def main():
    """
    Main function to demonstrate adding five numbers.
    """
    numbers = [10, 20, 30, 40, 50]
    result = add_five_numbers(*numbers)

    print(f"Adding the numbers: {numbers}")
    print(f"Sum: {result}")

    print("\nYou can also input your own numbers:")
    try:
        user_numbers = []
        for i in range(1, 6):
            num = float(input(f"Enter number {i}: "))
            user_numbers.append(num)

        user_result = add_five_numbers(*user_numbers)
        print(f"\nSum of your numbers: {user_result}")
    except ValueError:
        print("Invalid input. Please enter valid numbers.")
    except KeyboardInterrupt:
        print("\nProgram interrupted.")


if __name__ == "__main__":
    main()
