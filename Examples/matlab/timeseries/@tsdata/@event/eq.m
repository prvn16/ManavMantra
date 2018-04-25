function I = eq(e1,e2)
%EQ Compare event objects
%
%   E1 == E2 performs element-wise comparisons between tsdata.event arrays
%   E1 and E2.  E1 and E2 must be of the same dimensions unless one is a scalar.
%   The result is a logical array of the same dimensions, where each
%   element is an element-wise equality result.
%
%   If one of E1 or E2 is scalar, scalar expansion is performed and the 
%   result will match the dimensions of the array that is not scalar.
%
%   I = EQ(E1, E2) stores the result in a logical array of the same 
%   dimensions.

%   Copyright 2005-2013 The MathWorks, Inc.

% First, if e2 is empty, return false instead of error message
if isempty(e2)
    I = false;
    return
end

if numel(e1) == numel(e2)
    for k=numel(e1):-1:1
        I(k) = localCompare(e1(k),e2(k));
    end
    I = reshape(I,size(e1));
elseif isscalar(e2)
    for k=numel(e1):-1:1
        I(k) = localCompare(e1(k),e2);
    end
    I = reshape(I,size(e1));
elseif isscalar(e1)
    for k=numel(e2):-1:1
        I(k) = localCompare(e1,e2(k));
    end
    I = reshape(I,size(e2));
else
    error(message('MATLAB:tsdata:event:eq:sizeMismatch'))
end


function result = localCompare(e1,e2)

% If e2 is empty, return false instead of error message
if isa(e2,'tsdata.event')
    if isequal(e1.EventData,e2.EventData) && strcmp(e1.Name,e2.Name)
        if ~isempty(e1.StartDate) && ~isempty(e2.StartDate)
            result = (e1.Time*tsunitconv('days',e1.Units)+datenum(e1.StartDate) == ...
                e2.Time*tsunitconv('days',e2.Units)+datenum(e2.StartDate));            
        elseif isempty(e1.StartDate) && isempty(e2.StartDate)
            if isequal(e1.Units,e2.Units)
                result = (e1.Time==e2.Time);
            else
                result = (tsunitconv(e1.Time,'seconds')==tsunitconv(e2.Time,'seconds'));
            end
        else
            result = false;
        end             
    else
        result = false;
    end
else
    result = false;
end