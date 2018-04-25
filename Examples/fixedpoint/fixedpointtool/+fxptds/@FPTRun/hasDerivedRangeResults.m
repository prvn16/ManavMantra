function hasResults = hasDerivedRangeResults(this)
% HASDERIVEDRANGERESULTS returns true if run has derived min/max results.

%   Copyright 2013 The MathWorks, Inc.

results = this.getResults;

hasResults = false;
for i = 1:length(results)
    hasResults = hasResults || results(i).hasDerivedMinMax;
end 
