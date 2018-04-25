function [b,i,j] = unique(a,varargin)
%UNIQUE Find unique calendar durations in an array.
%   B = UNIQUE(A) returns the same calendar durations as in A but with no
%   repetitions. B is a vector sorted in ascending order.
%  
%   B = UNIQUE(A,'rows') for the calendar duration matrix A returns the unique
%   rows of A. The rows of the matrix B are sorted in ascending order.
%
%   [C,IA,IC] = UNIQUE(A) also returns index vectors IA and IC such that C =
%   A(IA) and A = C(IC). If A is a row vector, then C will be a row vector as
%   well, otherwise C will be a column vector. IA and IC are column vectors. If
%   there are repeated values in A, then IA returns the index of the first
%   occurrence of each repeated value.
%  
%   [C,IA,IC] = UNIQUE(A,'rows') also returns index vectors IA and IC such that
%   C = A(IA,:) and A = C(IC,:).
%
%   [C,IA,IC] = UNIQUE(A,OCCURRENCE) UNIQUE(A,'rows',OCCURRENCE) specify which
%   index is returned in IA in the case of repeated values (or rows) in A. The
%   default value for OCCURRENCE is 'first', which returns the index of the
%   first occurrence of each repeated value (or row) in A, while 'last' returns
%   the index of the last occurrence of each repeated value (or row) in A.
%  
%   [C,IA,IC] = UNIQUE(A,'stable') returns the values of C in the same order
%   that they appear in A, while UNIQUE(A,'sorted') returns the values of C in
%   sorted order.
%
%   [C,IA,IC] = UNIQUE(A,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while UNIQUE(A,'rows','sorted') returns the
%   rows of C in sorted order.
%
%   Example:
%      % Find the unique values in a vector of calendar durations that is not
%      % sorted and that contains repeated values.
%      caldur = calmonths([4 3 2 1 1 2 3 4])
%      unique(caldur)
%
%   See also CALENDARDURATION

%   Copyright 2017 The MathWorks, Inc.

components = a.components;

args = varargin;
rowsFlag = any(strcmp('rows',args));

scalarFields = [isscalar(components.months) isscalar(components.days) isscalar(components.millis)];
if all(scalarFields)
    % The input may be an all-zero or a non-zero scalar. Just return the input.
    % None of the flags have any effect.
    b = a;
    i = 1;
    j = 1;
    return
end
% If the array is not itself a scalar, then any scalar components are zero
% placeholders.

% In elements with a non-finite value in any component, put the same nonfinite
% across all non-placeholder components, so the core unique considers only that
% non-finite value, and never sees any finite values in the leading components.
% But leave scalar zero placeholders alone.
components = calendarDuration.reconcileNonfinites(components);

% Horzcat the components that are not zero placeholders into one numeric matrix.
% Components that are zero placeholders can safely be left out of the call to
% the core unique.
c = [];
if ~scalarFields(1) % months
    [c,width] = createCoreUniqueInput(c,components.months,rowsFlag);
end
if ~scalarFields(2) % days
    [c,width] = createCoreUniqueInput(c,components.days,rowsFlag);
end
if ~scalarFields(3) % millis
    [c,width] = createCoreUniqueInput(c,components.millis,rowsFlag);
end

% Find the unique rows of the matrix, i.e. the unique combinations of component
% values.
if rowsFlag
    [uc,i,j] = unique(c,args{:});
else
    [uc,i,j] = unique(c,'rows',args{:});
end

% Copy the input to the output, and overwrite the components that are not zero
% placeholders with the unique combinations of component values. Components that
% are zero placeholders can stay that way.
b = a;
k = 0;
if ~scalarFields(1) % months
    [b.components.months,k] = splitCoreUniqueOutput(uc,k,width,rowsFlag);
end
if ~scalarFields(2) % days
    [b.components.days,k] = splitCoreUniqueOutput(uc,k,width,rowsFlag);
end
if ~scalarFields(3) % millis
    [b.components.millis,k] = splitCoreUniqueOutput(uc,k,width,rowsFlag);
end

% The output is a column vector unless the input was a row vector.
if isrow(a) && ~rowsFlag, b = b'; end


%=======================================================================
function [c,width] = createCoreUniqueInput(c,component,rowsFlag)
% Horzcat the columnized component onto the input matrix. 'rows' is a special
% case: horzcat all the columns of the component. 'rows' on an N-D is an error.

if rowsFlag
    if ismatrix(component)
        width = size(component,2);
        c(:,end+(1:width)) = component;
    else
        error(message('MATLAB:UNIQUE:ANotAMatrix'));
    end
else
    width = 1;
    c(:,end+1) = component(:);
end


%=======================================================================
function [component,k] = splitCoreUniqueOutput(uc,k,width,rowsFlag)
% Pull off each columnized component from the output matrix and update the
% column index. 'rows' is a special case: pull off all the columns of the
% component.
if rowsFlag
    component = uc(:,k+(1:width));
    k = k + width;
else
    k = k + 1;
    component = uc(:,k);
end
