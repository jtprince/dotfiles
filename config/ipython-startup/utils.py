
def pdir(obj):
    return [att for att in dir(obj) if att[0] != '_']
