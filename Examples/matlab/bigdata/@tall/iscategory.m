function tf = iscategory(a,s)
%ISCATEGORY Test for categorical array categories.
%   TF = ISCATEGORY(A,CATEGORIES)
%
%   See also ISCATEGORY, TALL.

%   Copyright 2017 The MathWorks, Inc.

narginchk(2,2);

a = tall.validateType(a, mfilename, {'categorical'}, 1);

% Make sure chars get wrapped as strings so that dimensions are treated
% correctly later.
s = string(strtrim(s));
catList = categories(a);

if istall(s)
    % The result is elementwise in s, but we must broadcast the categories
    % list so that all partitions receive the same list.
    tf = elementfun( @ismember, s, matlab.bigdata.internal.broadcast(catList) );
    
else
    % Categories on a tall categorical always returns a small result, so if the
    % strings to compare are in-memory we can just use clientfun.
    tf = clientfun( @(x) ismember(s, x), catList );
end

% Result is always a logical array with the same size as S
outAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('logical');
sAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(s);
tf.Adaptor = outAdaptor.copySizeInformation(sAdaptor);

end

