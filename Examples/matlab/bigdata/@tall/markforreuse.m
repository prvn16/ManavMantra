function varargout = markforreuse(varargin)
%MARKFORREUSE Mark one or more tall arrays for reuse (i.e. caching).
%
%   X1 = MARKFORREUSE(X1) or MARKFORREUSE(X1) marks X1 for re-use. Where
%   possible the values in X1 will be cached after they are calculated so
%   that repeated use of X1 does not require repeated calculation. Caching
%   will be in memory up to the memory cache size limit, then on disk.
%
%   [X1,X2,..] = MARKFORREUSE(X1,X2,...) marks that all of X1, X2, ...
%   will be reused together in multiple iterations. Note that X1, X2, etc
%   must have the same tall size.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin == 1
    iMarkOneForReuse(varargin{1});
    if nargout
        varargout = varargin;
    end
else
    % For multiple inputs it is essential that the arrays are re-captured
    % at output
    assert(nargout == nargin, ...
       'When marking multiple arrays for reuse, all inputs are captured as outputs.');
    
    % Put all the inputs into one table and mark that for re-use
    arrayToCache = table(varargin{:});
    iMarkOneForReuse(arrayToCache);
    
    % Now convert the table back to individual variables
    [varargout{1:nargout}] = slicefun(@iTable2Vars, arrayToCache);
    for ii = 1:numel(varargin)
        varargout{ii}.Adaptor = copySizeInformation(...
            matlab.bigdata.internal.adaptors.getAdaptor(varargin{ii}), ...
            varargout{ii}.Adaptor);
    end
end
end

function iMarkOneForReuse(in)
% Mark one tall array/table for re-use
inImpl = hGetValueImpl(in);
if ~isa(inImpl, 'matlab.bigdata.internal.lazyeval.LazyPartitionedArray') || ~inImpl.ValueFuture.IsDone
    markforreuse(inImpl);
end
end

% Convert a table into a comma separated list of variables
function varargout = iTable2Vars(t)
varargout = varfun(@deal, t, 'OutputFormat', 'cell');
end