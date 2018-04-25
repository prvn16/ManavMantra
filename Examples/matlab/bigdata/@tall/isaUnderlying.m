function tf = isaUnderlying(t, c)
%isaUnderlying Determine if tall array data is of specified class
%   TF = isaUnderlying(T,C) returns logical 1 (TRUE) if the underlying data
%   in tall array T is of class C, and logical 0 (FALSE) otherwise. TF is a
%   tall array containing a logical scalar. Use GATHER(TF) to collect the
%   result into the MATLAB client session.
%
%   Example:
%      t = tall(rand(1,4));
%      c = isaUnderlying(t,'double')
%
%   See also: TALL, tall/classUnderlying.

% Copyright 2016 The MathWorks, Inc.

validateattributes(c, {'char'}, {'nonempty', 'row'}, mfilename, 'c', 2);

if ~isempty(t.Adaptor.Class)
    prototype = feval(str2func(sprintf('%s.empty', t.Adaptor.Class)));
    tf = tall.createGathered(isa(prototype, c), getExecutor(t));
else
    tf = getArrayMetadata(t, @(x) isa(x, c));
end
end
