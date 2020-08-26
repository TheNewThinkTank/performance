"""
Learnings:
Need over approx. 10_000_000 (or smaller) numbers before pyspark is faster than just running locally.
"""
import pyspark
import time
import matplotlib.pyplot as plt
from tqdm import tqdm
from os import path
import pandas as pd

if not 'sc' in globals():
    sc = pyspark.SparkContext()


def is_it_prime(number):
    # make sure n is a positive integer
    number = abs(int(number))
    # simple tests
    if number < 2:
        return False
    # 2 is prime
    if number == 2:
        return True
    # other even numbers aren't
    if not number & 1:
        return False
    # check whether number is divisible into it's square root
    for x in range(3, int(number ** .5)+1, 2):
        if number % x == 0:
            return False
    #  if we get this far we are good
    return True


def generate_data(n):
    data = []
    for numbers in tqdm(n):
        start = time.time()
        numbers_pyspark = sc.parallelize(range(numbers))  # create a set of numbers
        primes_pyspark = numbers_pyspark.filter(is_it_prime).count()
        # print('Number of primes: ', primes_pyspark)  # count out the number of primes
        execution_time_pyspark = time.time() - start
        # print("Spark time: ", execution_time_pyspark)

        start = time.time()
        primes_local = len(list(filter(is_it_prime, range(numbers))))
        # print(primes_local)
        execution_time_local = time.time() - start
        # print("Time without spark: ", execution_time_local)
        assert(primes_pyspark == primes_local)
        data.append([numbers, execution_time_pyspark, execution_time_local])

    df = pd.DataFrame(data, columns=['n', 'pyspark', 'local'])
    df.to_csv('data.csv')


def main():
    if not path.exists('data.csv'):
        data = generate_data(range(1, 500_000, 1_000))

    df = pd.read_csv('data.csv')
    df = df.iloc[1:]  # Remove 1st line
    df['ratio_local_pyspark'] = df['local'] / df['pyspark']
    print(df.head())

    # ax = df.plot(x='n', y='pyspark', logy=True, kind='line', color='b')
    # df.plot(x='n', y='local', logy=True, kind='line', color='r', ax=ax)

    df.plot(x='n', y='ratio_local_pyspark', kind='line', color='g')
    plt.hlines(y=1, xmin=1, xmax=500_000, colors='k', linestyles='solid')
    # df.plot(x='n', y='ratio_local_pyspark', logx=True, kind='line', color='g')  # if steps are unevenly spaced
    plt.savefig('ratio.png')
    # plt.savefig('data.png')
    plt.show()

    # plt.plot(text[0], text[1], 'b')
    # plt.plot(text[0], text[2], 'r')
    # plt.show()


if __name__ == "__main__":
    main()

# print("Number of pyspark cores", sc.defaultParallelism)  # 4
