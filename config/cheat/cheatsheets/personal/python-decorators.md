# Basic example

def lottery(func):
    def do_something(*args, **kwargs):
        print("before call")
        response = func(*args, **kwargs)
        if response == 9:
            response = 10000000
        return response

    return do_something


@lottery
def summit(x, y):
    return x + y


print(summit(4, 7))
print(summit(4, 5))

# before call
# 10000000
# before call
# 11
