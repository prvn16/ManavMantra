function b = lengthenVar(a,n)
% LENGTHENVAR Lengthen an existing variable data out to n rows.
%   LENGTHENVAR does not behave the same as DEFAULTARRAYLIKE. That method fills
%   in with missing values where it knows how to. This method is equivalent to
%   what gets filled in for the unassigned end+1st element when you assign to
%   the end+2nd element.
%
%   Consistent with standard MATLAB behavior, 0x0 vars will be lengthened to
%   Nx1, not as Nx0. Other empties will remain empty.

%   Copyright 2013-2017 The MathWorks, Inc.
m = size(a,1);

% assert(n > m)

b = a;
if isnumeric(a)
    % Let a numeric subclass pad with its choice, e.g. zero or NaN
    b(n+1,:) = 0; % preserves trailing shape for N-D
    b = b(1:n,:); % breaks trailing N-D shape
    if ~ismatrix(a)
        sizeOut = size(a); sizeOut(1) = n;
        b = reshape(b,sizeOut); % restore N-D shape
    end
elseif islogical(a)
    b(n,:) = false;
elseif isa(a,'categorical')
    b(n,:) = categorical.undefLabel;
elseif isa(a, 'datetime') 
    b(n,:) = NaT;
elseif isa(a, 'duration')
    b(n,:) = 0;
elseif isa(a, 'calendarDuration') 
    b(n,:) = calendarDuration(0,0,0);
elseif isstring(a)
    b(n,:) = missing;
elseif iscell(a)
    b(m+1:n,:) = {[]};
elseif ischar(a)
    b(n,:) = char(0);
elseif isenum(a)
    b(n,:) = matlab.lang.internal.getDefaultEnumerationMember(a);
elseif isstruct(a)
    fnames = fieldnames(a);
    b(n,:) = cell2struct(cell(size(fnames)),fnames);
    if isempty(b)
        % Empty structs don't grow correctly
        sizeOut = size(b); sizeOut(1) = n;
        b = reshape(b,sizeOut);
    end
elseif isa(a,'tabular')
    % Add new rows without touching any vars.
    b.rowDim = b.rowDim.lengthenTo(n);
    if b.varDim.length > 0
        % Lengthen each var in b with its default contents.
        for j = 1:length(b.data)
            b.data{j} = tabular.lengthenVar(b.data{j},n);
        end
    end
else % arbitrary objects
    % Get a scalar value from the array to be lengthened.
    if isempty(b)
        % There's no value to get, so get a default. This does not copy
        % any metadata from x that should be preserved.
        try
            b0 = feval(class(a));
        catch ME
            throwAsCaller(addCause(MException(message('MATLAB:table:ObjectConstructorFailed',class(a))),ME));
        end
    else
        b0 = b(1,:);
    end
    % Assign the value just past the desired end to fill the previous elements
    % with their default values. That scalar value is thrown away, so it doesn't
    % much matter what it is.
    b(n+1,:) = b0; % preserves trailing shape for N-D
    b = b(1:n,:); % breaks N-D shape
    if ~ismatrix(a)
        sizeOut = size(a); sizeOut(1) = n;
        b = reshape(b,sizeOut); % restore N-D shape
    end
end
