function tf = isOneToKSubscript(subscript)
%isOneToKIndexing - is a subscript value a valid non-empty 1:k subscript
%    TF = isOneToKIndexing(SUBS) returns TF = TRUE if
%    SUBS refers to a valid 1:K indexing expression. 

% Copyright 2015-2016 The MathWorks, Inc.

tf = isnumeric(subscript) && isvector(subscript) && ...
     ~isempty(subscript) && ...
     ( all(diff(subscript) == 1) || all(diff(subscript) == -1) ) && ...
     min(subscript) == 1;
end
