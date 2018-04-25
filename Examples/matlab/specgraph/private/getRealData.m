function args = getRealData(args, allowNonNumeric)
% This function is undocumented and may change in a future release.

   %  Copyright 2015-2017 The MathWorks, Inc.

   % getRealData returns the real components of ARGS. If ARGS contains any
   % complex data, a warning is displayed. If any of ARGS are not numeric
   % and cannot be converted to a double, an error is thrown.

narginchk(1, inf);
if nargin < 2
    allowNonNumeric = false;
end
foundcomplexdata = false;

for i = 1:length(args)
    v = args{i};
    if allowNonNumeric && (isa(v,'datetime') || isa(v,'duration') || isa(v,'categorical'))
        continue;
    end
    
    % If the object is not a standard numeric type, but does have a method
    % for converting it to double, try to do that now - exclude strings. 
    if ~isnumeric(args{i}) && ~isstring(args{i}) && (islogical(args{i}) || (ismethod(args{i},'double')))
        try
            args{i} = double(args{i});
        catch ME
            throwAsCaller(ME);
        end
    end
    
    % Now check that we have numeric data
    if isnumeric(args{i})
        
        % We have numeric data, keep just the real component.
        if ~isreal(args{i})
            foundcomplexdata = true;
            args{i} = real(args{i});
        end
        
    % If it is not numeric and cannot be converted to double, then error.
    elseif allowNonNumeric
        throwAsCaller(MException(message('MATLAB:specgraph:private:specgraph:nonNumericInputRulers')));
    else
        throwAsCaller(MException(message('MATLAB:specgraph:private:specgraph:nonNumericInput')));
    end
end

% If complex data was found, then produce a warning indicating that complex
% data is being ignored.
if(foundcomplexdata)
    warning(message('MATLAB:specgraph:private:specgraph:UsingOnlyRealComponentOfComplexData'));
end
