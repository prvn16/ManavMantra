function err = immse(x, y) %#codegen

% Copyright 2015 The MathWorks, Inc. 

%#ok<*EMCA>

validateattributes(x,{'uint8', 'int8', 'uint16', 'int16', 'uint32', 'int32', ...
    'single','double'},{'nonsparse'},mfilename,'A',1);
validateattributes(y,{'uint8', 'int8', 'uint16', 'int16', 'uint32', 'int32', ...
    'single','double'},{'nonsparse'},mfilename,'B',1);

% x and y must be of the same class
coder.internal.errorIf(~isa(x,class(y)),'images:validate:differentClassMatrices','A','B');

% x and y must have the same size
coder.internal.errorIf(~isequal(size(x),size(y)),'images:validate:unequalSizeMatrices','A','B');

if isa(x,'single')
    % if the input is single, return a single
    classToUse = 'single';
else
    % otherwise, return a double
    classToUse = 'double';
end

if isempty(x) % If x is empty, y must also be empty
    err = cast([],classToUse);
    return;
end

err = cast(0,classToUse);

numElems = numel(x);
for i = 1:numElems
    a = cast(x(i),classToUse);
    b = cast(y(i),classToUse);
    err = err + (a-b)*(a-b);
end
err = err/cast(numElems,classToUse);
