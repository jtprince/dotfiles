


def hstack_values(
    list_of_data: list[dict[str, np.array]], keys: list[str]
) -> dict[str, np.array]:
    """Concatenate values specified the keys.

    Example:
        data1 = {'a': np.array([1,2,3]), 'b': np.array([3,4,5])}
        data2 = {'a': np.array([6,7,8]), 'b': np.array([9,10,11])}
        combined = hstack_values([data1, data2], ['a', 'b'])
        # combined = {
        #    'a': array([1, 2, 3, 6, 7, 8]),
        #    'b': array([ 3,  4,  5,  9, 10, 11])
        # }
    """
    vec_lists_by_key = defaultdict(list)
    for key in keys:
        vec_list = [data[key] for data in list_of_data]
        vec_lists_by_key[key] = np.hstack(vec_list)
    return dict(vec_lists_by_key)

