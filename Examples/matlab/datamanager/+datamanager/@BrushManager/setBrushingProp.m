function setBrushingProp(h,varID,mfilename,fcnname,varargin)

% Find the index of this variable
if ischar(varID)
   ind = find(strcmp(varID,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
       strcmp(fcnname,h.DebugFunctionNames));
   varName = varID;
else
   ind = varID;
   varName = h.VariableNames{ind};
end

% Assign brushing properties
if isempty(ind)
    brushStruct = struct('I',[],'Color',[1 0 0]);
    h.SelectionTable = [h.SelectionTable;...
                       brushStruct];
    h.VariableNames = [h.VariableNames;...
                      {varName}];
    h.DebugMFiles = [h.DebugMFiles;...
                      {mfilename}];
    h.DebugFunctionNames = [h.DebugFunctionNames;...
                      {fcnname}];
    ind = length(h.SelectionTable);
end
for k=1:length(varargin)/2
    h.SelectionTable(ind).(varargin{2*k-1}) = varargin{2*k};
end

