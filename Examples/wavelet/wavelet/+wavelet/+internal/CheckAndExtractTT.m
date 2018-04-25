function [x,VariableNames] = CheckAndExtractTT(tt)

% Check the number of variables in the time table
NumVar = numel(tt.Properties.VariableNames);
VariableNames = tt.Properties.VariableNames;
% If there is one variable, that variable must be a vector or matrix
if NumVar == 1
which = find(varfun(@(x) ismatrix(x) && all(isfinite(x(:))),tt,'output','uni'));
if isempty(which)
    error(message('Wavelet:FunctionInput:OneVariableTT'));
else
    x = extractWhich(tt,which);
end


% If the number of variables is greater than 1, then each numeric variable must be
% a vector. We do not support multiple matrix inputs.
elseif NumVar>1 
    which = find(varfun(@(x) isvector(x) && isnumeric(x) && ...
        all(size(x,2) == 1),tt,'output','uni'));
    if isempty(which)
        error(message('Wavelet:FunctionInput:MultipleMatrixTT'));
    else
        x = extractWhich(tt,which);
        
    end
    
end
    
%---------------------------------------------------------------------
function x = extractWhich(tt,which)
x = [];
for kk = 1:length(which)
    x = [x  tt.(which(kk))]; %#ok<AGROW>
end


    
    

