"""
Learnings:
Need over approx. 10_000_000 (or smaller) numbers,
before pyspark is faster than just running locally.
"""

import time
from os import path
from typing import Iterable

import matplotlib.pyplot as plt
import pandas as pd
import pyspark
from tqdm import tqdm

if 'sc' not in globals():
    sc = pyspark.SparkContext()


# TODO: use algo-lib prime function here instead
def is_it_prime(number: int) -> bool:
    """Check if a number is prime."""

    number = abs(number)  # make sure n is a positive integer
    # simple tests
    if number < 2:
        return False
    if number == 2:  # 2 is prime
        return True
    if not number & 1:  # other even numbers aren't
        return False
    # check whether number is divisible into it's square root
    for x in range(3, int(number ** .5) + 1, 2):
        if number % x == 0:
            return False
    #  if we get this far we are good
    return True


def generate_data(n: Iterable) -> None:
    """Save execution time of local and pyspark runs to a CSV file."""

    data = []

    for numbers in tqdm(n):

        start = time.time()
        numbers_pyspark = sc.parallelize(range(numbers))  # create a set of numbers
        primes_pyspark = numbers_pyspark.filter(is_it_prime).count()
        execution_time_pyspark = time.time() - start

        start = time.time()
        primes_local = len(list(filter(is_it_prime, range(numbers))))
        execution_time_local = time.time() - start

        assert(primes_pyspark == primes_local)
        data.append([numbers, execution_time_pyspark, execution_time_local])

    df = pd.DataFrame(data, columns=['n', 'pyspark', 'local'])
    df.to_csv('data.csv')


def main() -> None:
    """Driver function."""

    print("Number of pyspark cores", sc.defaultParallelism)  # 4

    if not path.exists('data.csv'):
        generate_data(range(1, 500_000, 1_000))

    df = pd.read_csv('data.csv')
    df = df.iloc[1:]  # Remove 1st line
    df['ratio_local_pyspark'] = df['local'] / df['pyspark']
    print(df.head())

    df.plot(x='n', y='ratio_local_pyspark', kind='line', color='g')

    # if steps are unevenly spaced:
    # df.plot(x='n', y='ratio_local_pyspark', logx=True, kind='line', color='g')

    plt.hlines(y=1, xmin=1, xmax=500_000, colors='k', linestyles='solid')
    plt.savefig('ratio.png')  # 'data.png'
    plt.show()


if __name__ == "__main__":
    main()
