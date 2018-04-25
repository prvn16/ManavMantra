function y = datachk(x, kind)
%DATACHK Convert input to appropriate data for plotting
%  Y=DATACHK(X) creates a full, double array from X and returns it in Y.
%  If X is a cell array each element is converted elementwise.
%  Y=DATACHK(..., KIND) customizes the check depending on KIND. KIND
%  can be
%    'double' (default): outputs are converted to full double
%    'numeric':          outputs are numeric and allow conversion to 
%                        double for non-numeric values. Double values are made full.

%   Copyright 1984-2016 The MathWorks, Inc. 

if nargin == 1
    kind = 'double';
end
if iscell(x)
    y = cellfun(@(n)datachk(n,kind),x,'UniformOutput',false);
elseif isa(x,'double')
    y = full(x);
elseif strcmp(kind,'numeric') && isnumeric(x)
    y = x;
else
    try
        y = full(double(x));
    catch
        throwAsCaller(MException(message('MATLAB:specgraph:private:specgraph:nonNumericInput')));
    end
end
