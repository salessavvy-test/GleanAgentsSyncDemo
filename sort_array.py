#!/usr/bin/env python3
"""
Utility module to sort a list of numbers in ascending order.

This module exposes a single reusable function, `sort_array`, which accepts any
iterable of ints or floats and returns a new list sorted in ascending order.
"""

from typing import Iterable, List, Union

Number = Union[int, float]


def sort_array(values: Iterable[Number]) -> List[Number]:
    """Return a new list containing `values` sorted in ascending order.

    Args:
        values: An iterable of numeric values (ints or floats).

    Returns:
        A new list with the numbers from `values` sorted in ascending order.

    Note:
        This function does not mutate the input iterable; it always returns
        a new list instance.
    """

    return sorted(values)
