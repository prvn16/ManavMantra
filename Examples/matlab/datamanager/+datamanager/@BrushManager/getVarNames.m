function [varNames,I] = getVarNames(h,mfilename,fcnname)

% Returns the names of variables brushed within a particular workspace
I = find(strcmp(mfilename,h.DebugMFiles) & strcmp(fcnname,h.DebugFunctionNames));
varNames = h.VariableNames(I);


