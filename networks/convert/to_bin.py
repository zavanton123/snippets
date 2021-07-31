def convert_to_bin():
    while True:
        num = input("Enter the decimal: ")
        result = bin(int(num))
        print("Result: ")
        print(result)


if __name__ == '__main__':
    convert_to_bin()
