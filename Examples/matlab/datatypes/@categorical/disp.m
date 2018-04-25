function disp(a,name)
%DISP Display a categorical array.
%   DISP(A) prints the categorical array A without printing the array name.
%   In all other ways it's the same as leaving the semicolon off an
%   expression, except that empty arrays don't display.
%
%   See also CATEGORICAL/CATEGORICAL, DISPLAY.

%   Copyright 2006-2016 The MathWorks, Inc. 

if isempty(a)
    return;
end

if (nargin < 2)
    name = '';
end

% Let the cell disp method do the real work
catnames = [categorical.undefLabel; a.categoryNames];
catnames = strrep(catnames, '''', char(1)); %#ok<NASGU>
s = evalc('disp(reshape(catnames(a.codes+1),size(a.codes)))');

% *** Update COMMENT (if given name need to display.... blahblahblahb)
% For N-D arrays, output captured from the cell disp output contains page
% headers like '(:,:,1) ='. Since the default display method has already put
% up the 'obj =' line. find the page headers and remove the '='.
if ~ismatrix(a)
    s = regexprep(s,'(\([0-9:,]+\))', [name '$1']);
end

s = strrep(s, '''', ' ');
s = strrep(s, char(1), '''');
fprintf('%s',s);