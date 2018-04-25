function names = numericBinEdgesToCategoryNames(edges,closedRight)
%NUMERICBINEDGESTOCATEGORYNAMES Generate category names from bin edges
%   NAMES = NUMERICBINEDGESTOCATEGORYNAMES(EDGES,CLOSEDRIGHT) returns a cell
%   array of character vectors that are the names corresponding to the bins 
%   defined by EDGES. Category names are in the form of "[A,B)" (or "[A,B]" 
%   for the last bin), where A and B are consecutive bin edges. CLOSEDRIGHT 
%   is a logical scalar. If CLOSEDRIGHT is true, sthe bins are right-aligned, 
%   and the category names are in the form of "(A,B]" (or "[A,B]" for the 
%   first bin).

%   Copyright 2016-2017 The MathWorks, Inc.

if closedRight
    leftedge = '(';
    rightedge = ']';
else
    leftedge = '[';
    rightedge = ')';    
end

nbins = length(edges)-1;
names = cell(1,nbins);
for i = 1:nbins
    names{i} = sprintf([leftedge '%0.5g, %0.5g' rightedge],edges(i),edges(i+1));
end

% Put the correct delimiter at the "opposite" extreme limit.
if closedRight
    names{1}(1) = '[';
else
    names{end}(end) = ']';
end

% If the edges are not distinguishable using 5 digits, error. Do this after
% replacing the extreme delimiter. It can happen that the 1st and 2nd bin, or
% the (N-1)st and Nth bins, would differ subtlely only by a [ vs. ( or ] vs. )
% after that replacement. Allowing this is this is intentional. Note that this
% will allow up to three repeated edge values at either extreme, but not in
% the middle.
if length(unique(names)) < length(names)
    error(message('MATLAB:discretize:DefaultCategoryNamesNotUnique'));
end
