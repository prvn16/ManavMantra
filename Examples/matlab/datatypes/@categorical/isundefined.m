function tf = isundefined(a)
%ISUNDEFINED True for elements of a categorical array that are undefined.
%   TF = ISUNDEFINED(A) returns a logical array the same size as the categorical
%   array A, containing logical 1 (true) where the corresponding element of A is
%   undefined, i.e., does not have a value from one of the categories in A,
%   and logical 0 (false) otherwise.
%
%   See also ISMISSING, ISMEMBER.

%   Copyright 2006-2016 The MathWorks, Inc. 

tf = (a.codes == 0);
