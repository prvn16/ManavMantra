function P = get(A, name)
%GET Get property values of fimath object
%   V = GET(A, 'PropertyName') returns the value of the specified 
%   properties for the fi object, A. If 'PropertyName' is replaced
%   by a cell array of strings containing property names, GET returns
%   a cell array of values.
%
%   S = GET(A) returns all properties of fimath object A in a scalar structure.
%

%   Copyright 2016-2017 The MathWorks, Inc.


if nargin > 1
    name = convertStringsToChars(name);
end

if nargin == 1
    if ~isscalar(A)
        error(message('MATLAB:class:get:ScalarRequired'));
    end
    for pn = properties(A)'
        S.(pn{1}) = A.(pn{1});
    end
    if nargout == 1
        P = S;
    else
        disp(S);
    end
    
elseif nargin == 2
     rows = 1; 
    if iscellstr(name)
        cols = numel(name);
        P = cell(rows, cols);
        for i = 1:cols
            [P{:,i}] = A.(name{i});
        end
    elseif ischar(name)
       % if (rows == 1)
         P = A.(name);
       % else
       %     [P{1:rows, 1}] = A.(name);
       % end
    else
        error(message('MATLAB:class:InvalidArgument', 'get','get'));
    end
end

end %function

