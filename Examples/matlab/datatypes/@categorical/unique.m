function [b,i,j] = unique(a,varargin)
%UNIQUE Unique values in a categorical array.
%   C = UNIQUE(A) returns a categorical array containing the same values as in
%   A but with no repetitions. C is sorted by the order of A's categories.
%  
%   C = UNIQUE(A,'rows') for the categorical matrix A returns the unique rows
%   of A. The rows of the matrix C are sorted by the order of A's categories.
%
%   [C,IA,IC] = UNIQUE(A) also returns index vectors IA and IC such that
%   C = A(IA) and A = C(IC). If A is a row vector, then C will be a row vector
%   as well, otherwise C will be a column vector. IA and IC are column vectors.
%   If there are repeated values in A, then IA returns the index of the first
%   occurrence of each repeated value.
%  
%   [C,IA,IC] = UNIQUE(A,'rows') also returns index vectors IA and IC such
%   that C = A(IA,:) and A = C(IC,:). 
%
%   [C,IA,IC] = UNIQUE(A,OCCURRENCE) and UNIQUE(A,'rows',OCCURRENCE) specify
%   which index is returned in IA in the case of repeated values (or rows) in A.
%   The default value for OCCURRENCE is 'first', which returns the index of the
%   first occurrence of each repeated value (or row) in A, while 'last' returns
%   the index of the last occurrence of each repeated value (or row) in A.
%  
%   [C,IA,IC] = UNIQUE(A,'stable') returns the values of C in the same order
%   that they appear in A, while [C,IA,IC] = UNIQUE(A,'sorted') returns the
%   values of C in sorted order.
% 
%   [C,IA,IC] = UNIQUE(A,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while [C,IA,IC] = UNIQUE(A,'rows','sorted')
%   returns the rows of C in sorted order.
% 
%   UNIQUE(A,'legacy'), UNIQUE(A,'rows','legacy'), UNIQUE(A,OCCURRENCE,'legacy'),
%   and UNIQUE(A,'rows',OCCURRENCE,'legacy') preserve the behavior of the UNIQUE
%   function from R2012b and prior releases.
%
%   See also UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2006-2015 The MathWorks, Inc.

narginchk(1,Inf);

if nargin > 1 && ~matlab.internal.datatypes.isCharStrings(varargin)
    error(message('MATLAB:categorical:setmembership:UnknownInput'));
end

acodes = a.codes;

% Rely on built-in's NaN handling if input contains any <undefined> elements
acodes = categorical.castCodesForBuiltins(acodes);

try
    if nargout > 1
        [bcodes,i,j] = unique(acodes,varargin{:});
    else
        bcodes = unique(acodes,varargin{:});
    end
catch ME
    throw(ME);
end

if isfloat(bcodes)
    % Cast back to integer codes, including NaN -> <undefined>
    bcodes = categorical.castCodes(bcodes,length(a.categoryNames));
end
b = a; % preserve subclass
b.codes = bcodes;

