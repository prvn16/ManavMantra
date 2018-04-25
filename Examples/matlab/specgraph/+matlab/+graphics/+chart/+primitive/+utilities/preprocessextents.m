function [ varargout ] = preprocessextents( in )
% PREPROCESSEXTENTS removes nonfinite data
%     OUT = PREPROCESSEXTENTS(IN)
%     Removes non finite data from input vector, IN.  
%
%     [VARARGOUT] = PREPROCESSEXTENTS(IN)
%     If input is an array, removes entire row of data if any element is
%     nonfinite and returns each column independently in varargout, etc.
%     If number of output arguments is more than the number of input
%     columns, a scalar 0 will be reported for all remaining outputs. 

%   Copyright 2012-2013 The MathWorks, Inc.

if (size(in,2) >= 2)
    
    if all(isfinite(in(:)))
        finitearray = in;
    else
        % if any row contains a NaN or Inf, delete entire row
        finitearray = in(isfinite(sum(in,2)),:);
    end
    
    varargout = cell(nargout,1);
    for i = 1:size(finitearray,2)
        varargout{i} = finitearray(:,i);
    end
    
    % We get here if we have an input of [xdata, ydata, zdata] and zdata is
    % empty - we would like to return 0 for zdata in this case
    for i = size(finitearray,2)+1:nargout
        varargout{i} = 0;
    end
else
    vec = in(:);
    varargout{1} = vec(isfinite(vec));
end