function y = defaultarrayLike(sz,~,x)
%DEFAULTARRAYLIKE Create a variable like x containing null values
%   Y = DEFAULTARRAYLIKE(SZ,'Like',X) returns a variable the same class as X,
%   with the specified size, containing default values.  The default value for
%   floating point types is NaN, in other cases the default value is the value
%   MATLAB uses by default to fill in unspecified elements on array expansion.
%
%      Array Class            Null Value
%      ---------------------------------------------
%      double, single         NaN
%      duration               NaN
%      calendarDuration       NaN
%      datetime               NaT
%      int8, ..., uint64      0
%      logical                false
%      categorical            <undefined>
%      char                   char(0)
%      cellstr                {''}
%      cell                   {[]}
%      string                 string('')
%      struct                 struct with [] in fields
%      table                  table with vars recursively filled in
%      other                  [MATLAB default value]

%   Copyright 2012-2017 The MathWorks, Inc.

n = sz(1); p = prod(sz(2:end));
if isfloat(x)
    y = nan(sz,'like',x);
elseif isnumeric(x)
    y = zeros(sz,'like',x);
elseif islogical(x)
    y = false(sz);
elseif isa(x,'categorical')
    y = x(1:0);
    if n*p > 0
        y(n,p) = categorical.undefLabel;
    end
    y = reshape(y,sz);
elseif isa(x, 'datetime') 
    y = NaT(sz);
    y.Format = x.Format;
    y.TimeZone = x.TimeZone;
    
% duration and calendarDuration fill with 0, set to NaN explicitly
elseif isa(x, 'duration') 
    y = duration(NaN(sz),0,0);
    y.Format = x.Format;
elseif isa(x, 'calendarDuration') 
    y = calendarDuration(NaN(sz),0,0);
    y.Format = x.Format;
    
elseif isstring(x)
    y = repmat(string(nan),sz);
elseif iscell(x)
    if iscellstr(x)
        y = repmat({''},sz);
    else
        y = cell(sz);
    end
elseif ischar(x)
    y = repmat(char(0),sz);
    
elseif isenum(x)
    y = repmat(matlab.lang.internal.getDefaultEnumerationMember(x),sz);
    
elseif isstruct(x)
    fnames = fieldnames(x);
    y = repmat(cell2struct(cell(size(fnames)),fnames),sz);
    
elseif isa(x,'tabular')
    % This ignores all but the first element of sz, and creates a table
    % with the same vars/types as x, with their default contents.
    if width(x) > 0
        y = varfun(@(var)defaultarrayLikeWrapper(var,n),x);
    else
        y(1:n,:) = array2table(zeros(n,0));
    end
    y.Properties.VariableNames = x.Properties.VariableNames;
    
else % fallback for unrecognized types
    % Create an empty version of the input, then assign off the end to let the
    % class decide how it wants to fill in default values. That may or may not
    % be the same as what the class constructor returns for no inputs.
    y = x(1:0);
    if n*p > 0
        % If the output is non-empty, assign get a scalar value from the
        % template and assign it just past the desired end to fill the previous
        % elements with their default values. That scalar value will be thrown
        % away, so it doesn't much matter what it is.
        if isempty(x)
            % There's no value to get, so get a default. This does not copy any
            % metadata from x that should be preserved.
            try
                x0 = feval(class(x));
            catch ME
                throwAsCaller(addCause(MException(message('MATLAB:table:ObjectConstructorFailed',class(x))),ME));
            end
        else
            x0 = x(1);
        end
        y(n*p+1) = x0;
    end
    % Reshape the default elements to the output size
    y = reshape(y(1:n*p),sz); % fails if the class does not support reshape
end

function y = defaultarrayLikeWrapper(x,n)
szOut = size(x); szOut(1) = n;
y = matlab.internal.datatypes.defaultarrayLike(szOut,'like',x);

