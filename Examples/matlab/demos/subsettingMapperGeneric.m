function subsettingMapperGeneric(data, ~, intermKVStore, subsetter)

intermKey = 'Null';

intermVal = data(subsetter(data), :);

add(intermKVStore,intermKey,intermVal);
