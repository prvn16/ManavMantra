function propval = getBrushingProp(h,varID,mfilename,fcnname,propName)

propval = [];

% Find the index of this variable
if ischar(varID)
   ind = find(strcmp(varID,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
       strcmp(fcnname,h.DebugFunctionNames));
else
   ind = varID;
end


% Get brushing properties
if ~isempty(ind)
    propval = h.SelectionTable(ind).(propName);
end