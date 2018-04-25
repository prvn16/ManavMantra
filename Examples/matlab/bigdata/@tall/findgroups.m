function [tx, varargout] = findgroups(varargin)
%FINDGROUPS Find groups and return group numbers
%   Supported syntaxes for tall arrays:
%   G = FINDGROUPS(A)
%   G = FINDGROUPS(A1,A2,...)
%   [G,GID1,GID2,...] = FINDGROUPS(A1,A2,...)
%
%   Limitations:
%   1) Tall table input is not supported.
%   2) G the group number may be in different order from non-tall implementation.
%
%   See also FINDGROUPS.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,inf);
nargoutchk(0, nargin+1);
for k = 1:nargin
    varargin{k} = tall.validateVector(varargin{k}, ...
        'MATLAB:findgroups:GroupingVarNotVector');
end
tx = findgroupsViaCategorical(varargin{:});
% Get group names out.
if nargout > 1
    [varargout{1:nargin}] = splitapply(@applyExtractFirstRow, varargin{:}, tx);
end
end

function tx = findgroupsViaCategorical(varargin)
% For each chunk, using categorical arrays to combine inputs.
% tc is not a proper tall categorical array because each chunk can have
% different categories.
tc = elementfun(@localCategorical,varargin{:});
tc = setKnownType(tc, 'categorical');
% Now construct a tall categorical array which will ensure all chunks have 
% the same categories. The double group ids for a tall categorical arrays
% are the group numbers.
tx = double(categorical(tc));
end

function tc = localCategorical(varargin)
% Create categorical array from all inputs.
% Each categorical will correspond to a group index.
tc = categorical(varargin{1});
% Remove any unused categories in-case the original input was a categorical
% that contained unused categories. This may remove categories that are
% used in other chunks, these will be re-added by the tall categorical
% constructor.
tc = removecats(tc);
sizetc = size(tc);
if ~all(cellfun(@(x)isequal(size(x),sizetc), varargin))
    error(message('MATLAB:findgroups:InputSizeMismatch'));
end
for i = 2:nargin
    tc = removecats(tc.*categorical(varargin{i}));
end
end

function varargout = applyExtractFirstRow(varargin)
% Function applied via splitapply to get the group IDs.
% splitapply is applied to the groups themselves using this function to
% extracts the first row and make sure that the correct adaptor is applied.
[varargout{1:nargin}] = reducefun(@extractFirstRow, varargin{:});
for k = 1:nargin
    varargout{k}.Adaptor = resetTallSize(matlab.bigdata.internal.adaptors.getAdaptor(varargin{k}));
end
end

function varargout = extractFirstRow(varargin)
% Helper to get the first row of a group while coping with the possibility of
% empty groups.
varargout = cell(size(varargin));
for k = 1:nargin
    z = varargin{k};
    assert(~isempty(z), "Hit empty group. FINDGROUPS use of SPLITAPPLY should not be generating empty groups.");
    varargout{k} = z(1,:);
end
end

