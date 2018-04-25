function O = consume_assign(O, base, l, X, varargin)

%   Copyright 2007 The MathWorks, Inc.
%   $Revision $ 

% First, calculate the extent of X along the l^th axis.
k = length(varargin); % the number of indices
assert(k > 0);        % otherwise, flow does not arrive here
if k == 1
    extent = length(X); % because X is or is being treated as a vector
else
    extent = size(X,l); % X is at least l-dimensional
end
% The job of this function is to fill in the slice of O in the range from
% base+1:base+extent with the values of X (which were computed in the worker).
% This function is called only on error of the "natural" assignment:
%
%          O(varargin[J->base+1:base+extent]) = X;
%
% Because the entire slice of O was sent to the worker, this error happens
% (so far as I know) only when O is empty or a struct, X is a struct, and
% X has more fields than O.  To check this fact:
assert((isempty(O) || isstruct(O)) && isstruct(X))
% It would seem that one can simply loop through the fields of X, setting the
% corresponding elements of O.
varargin{l} = base+1:base+extent;
fields = fieldnames(X);
for i = 1:length(fields)
    f = fields{i};
    [O(varargin{:}).(f)] = X.(f);
end
