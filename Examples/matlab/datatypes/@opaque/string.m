function str = string(jobj)
%STRING Convert a Java object or array of objects to a MATLAB string
%  STR = string(JOBJ) returns a string array STR the same size and dimensions as
%  the Java array JOBJ, setting each STR member to the equivalent value of the
%  JOBJ member's toString() method.
%
%  If the JOBJ is not rectangular, the length of STR's dimensions will be
%  equal to the maximum length of the corresponding dimension of JOBJ.
%  Nonexistent and null elements in JOBJ result in <missing> elements in STR.
%
%  Unlike the char function, this returns the value of toString() for objects
%  of type java.lang.Number even if the class of JOBJ is java.lang.Object.

%   Copyright 2016-2017 The MathWorks, Inc.

    function str = jstring2string(jstr)
    % Convert a Java string vector or scalar into a string vector.  Input may be
    % null, or may have null elements, which get converted to <missing>.
        if isempty(jstr)
            str = string(NaN);
        else
            % we don't have a builtin to directly convert a Java String scalar or
            % vector to a string, but we can convert it to a cell array of chars.
            cel = cell(jstr);
            if ~iscellstr(cel)
                % If it's not a cellstr, it's because it had [] cells where
                % the input had nulls, so convert one cell at a time. 
                str(length(cel)) = string(NaN); % preallocate with <missing>
                for i = 1 : length(cel)
                    ch = cel{i};
                    if ischar(ch)
                        % if not char, it must be [] which stays <missing>
                        str(i) = string(ch);
                    end
                end
            else
                % convert the cellstr to a string all at once
                str = string(cel);
            end
        end
    end

    % Optimize the most common case: a scalar java.lang.String becomes a scalar string
    if isa(jobj, 'java.lang.String')
        str = jstring2string(jobj);
        return;
    end

    % Next most common case: call toString on any scalar.  Test using Java's isArray
    % instead of MATLAB's isScalar, because isScalar returns true for 1-element
    % Java array, and we need to treat that as an array, not a scalar.  Anyway
    % isScalar bombs if the object doesn't implement toDouble.
    if ~jobj.getClass.isArray()
        str = jstring2string(javaMethod('toString', jobj));
        return;
    end

    % So it must be a Java array.  Get number of Java dimensions by counting ['s in
    % class name.
    className = char(jobj.getClass.getName());
    nameStart = find(className ~= '[', 1);
    ndims = nameStart - 1; 
    assert(ndims > 0);
    
    % dims(i) will eventually be the length of the i'th dimension, which is the maximum
    % length of any of the vectors at the i'th dimension.
    dims = zeros(1, ndims, 'int32');
    % fill in the values of dims, to get size of the resulting array
    getMaxDim(jobj, 1);
    
    % preallocate rectangular str array with the required number of dimensions and
    % lengths and initialize it with <missing> in all elements
    if ndims == 1 && dims > 0
        % Special case of single dimension of nonzero size, insure we create column
        % vector instead of square matrix
        str(dims,1) = string(NaN); 
    else
        str = repmat(string(NaN), dims); 
    end
    if any(dims == 0)
        return;
    end
    
    basicClass = className(nameStart:end);
    isString = strcmp(basicClass, 'Ljava.lang.String;');
    
    % copy all non-null elements of jobj into their proper positions in str
    fill(jobj);

    function getMaxDim(jobj, dim)
    % Fill in dims with the maximum number of elements at each dimension. For jobj, a
    % possibly multidimensional jobj array, set dims(dim) to the max of it and the
    % length of jobj, bump dim and recurse on each child of jobj.
        assert(isempty(jobj) || jobj.getClass.isArray); % false if we recursed too far
        % length of Java array refers to immediate children
        dims(dim) = max([dims(dim) length(jobj)]);
        if dim < length(dims) 
            % If not yet at the bottom level, recurse on each child, stopping at the
            % last dimension, which points to the array elements
            arrayfun(@(array) getMaxDim(array, dim+1), jobj);
        end
    end

    function fill(jobj, indices, dim)
    % Insert the stringified value of each element of the multidimensional java array
    % jobj into the same-indexed element of str.  Original caller supplies just jobj.
    % indices and dim arguments are for recursion as we go down the dimensions
        if nargin == 1
            % indices is cell array of indices into element of str that we are working
            % on.  Need to have it as a cell array so we can use its members as indices.
            indices = num2cell(ones(1, ndims));
            % dim is the dimension into indices that we are working on
            dim = 1;
        end
        % Loop through each member of jobj.  If the Java array element from which jobj
        % was fetched was null, jobj is [].  If it was an empty array, jobj is an empty
        % Java array.  In both cases we ignore it and all descendents beneath it will
        % remain <missing>.
        if isString && dim == length(dims)
            % In the most common case, if the object was a Java String array, then
            % we can call our string conversion function directly on each bottom-level
            % string vector, instead of recursing to do one element at a time.
            js = jstring2string(jobj);  % result's length is equal to jobj length
            str(indices{1:dim-1},1:numel(js)) = js;  % unfilled elements correspond to nulls, which stay <missing>
        else
            for i = 1 : length(jobj)
                % i is the dim'th index
                indices{dim} = i;
                if length(dims) > dim
                    % not at bottom level, so recurse, passing in the indices we are working
                    % on and the dimension (position in indices)
                    fill(jobj(i), indices, dim+1);
                else
                    % We're at the bottom level, where jobj(i) is the Java array element to
                    % stringify and insert into str.  Use callJava on Array.get() to fetch
                    % it, instead of indexing directly, to assure we get a Java Object,
                    % instead of having it automatically converted to a MATLAB type, which
                    % happens when jobj is of type Object.  This is to be sure we get Java's
                    % toString() value out of it--converting to a MATLAB type could lose
                    % precision (e.g., Long is converted to double), and string() on a
                    % double or float returns a format different from toString().
                    element = matlab.internal.callJava('get', 'java.lang.reflect.Array', jobj, i-1);
                    if ~isempty(element)
                        % Look only at nonempty elements.  An empty element means it was a
                        % Java null, which we leave as <missing>.
                        if ~isString
                            % Call toString if it isn't already String.  Note that
                            % element might be an array, in the unlikely case that jobj
                            % is an Object array which has an array as an element.  In
                            % this case toString will return something like
                            % "[Ljava.lang.Object;@72c4504"
                            element = javaMethod('toString', element);
                        end
                        str(indices{:}) = jstring2string(element);
                    else % empty else for code coverage
                    end
                end
            end
        end
    end
end

