function varargout = histcounts(tallX, varargin)
%HISTCOUNTS  Histogram Bin Counts.
%   Supported syntaxes for tall X:
%   [N,EDGES] = HISTCOUNTS(X)
%   [N,EDGES] = HISTCOUNTS(X,M)
%   [N,EDGES] = HISTCOUNTS(X,EDGES)
%   [N,EDGES] = HISTCOUNTS(...,'BinWidth',BW)
%   [N,EDGES] = HISTCOUNTS(...,'BinLimits',[BMIN,BMAX])
%   [N,EDGES] = HISTCOUNTS(...,'Normalization',NM)
%   [N,EDGES] = HISTCOUNTS(...,'BinMethod',BM) - BM can be 'auto' (default),
%               'scott', 'integers', 'sturges', 'sqrt'
%   [N,EDGES,BIN] = HISTCOUNTS(...) also returns an index array BIN
%
%   Supported syntaxes for tall categorical C:
%   N = HISTCOUNTS(C)
%   N = HISTCOUNTS(C, CATEGORIES)
%   N = HISTCOUNTS(...,'Normalization',NM)
%   [N,CATEGORIES] = HISTCOUNTS(...)
%
%   See also HISTCOUNTS, CATEGORICAL/HISTCOUNTS

%   Copyright 2016-2017 The MathWorks, Inc.

tallX = tall.validateType(tallX, mfilename, {'numeric', 'logical', 'categorical'}, 1);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

if isequal(tallX.Adaptor.Class, 'categorical')
    nargoutchk(0,2);
    [varargout{1:max(nargout,1)}] = histcountsCategorical(tallX, varargin{:});
else
    nargoutchk(0,3);
    tallX = lazyValidate(tallX, {@isreal, 'MATLAB:bigdata:array:ArgMustBeTallReal', 1, mfilename});
    [varargout{1:max(nargout,1)}] = histcountsData(tallX, varargin{:});
end

end
