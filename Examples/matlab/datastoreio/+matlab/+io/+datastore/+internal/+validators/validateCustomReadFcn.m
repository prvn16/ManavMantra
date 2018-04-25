function validateCustomReadFcn(readFcn, fromConstructor, datastoreName)
    if isa(readFcn, 'function_handle') && nargin(readFcn) ~= 0
        return;
    end
    if fromConstructor
        error(message('MATLAB:datastoreio:customreaddatastore:invalidReadFcnFromXtor', datastoreName));
    else
        error(message('MATLAB:datastoreio:customreaddatastore:invalidReadFcn'));
    end
end
