function [topLeftVal,outBooleanArray,numcols,jColor] = getArrayEditorBrushCache(varName,...
    topRow,topColumn,MINROWCOUNT,MINCOLUMNCOUNT)

% Static method for BrushTableModel.java to obtain the Brushing Array
% cache for a particular variable varName displayed in the Variable Editor.

%   Copyright 2007-2008 The MathWorks, Inc.

% Get the current mfile,fcnname
[mfilename,fcnname] = datamanager.getWorkspace(1);
parenStart = strfind(varName,'(');
subsstr = '';
if ~isempty(parenStart)
    subsstr = varName(parenStart:end);
    varName = varName(1:parenStart(1)-1);    
end

% Find the current variable in the brushing manager
h = datamanager.BrushManager.getInstance();
ind = find(strcmp(varName,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
       strcmp(fcnname,h.DebugFunctionNames));
   
% Get the brushing array
if ~isempty(ind) && ~isempty(h.SelectionTable(ind(1)).I)
    I = h.SelectionTable(ind(1)).I;
    thisColor = h.SelectionTable(ind).Color;
else
    try 
        I = evalin('caller',sprintf('false(size(%s));',varName)); 
    catch
        I = false;
    end
    thisColor = [1 0 0];
end
topRow = topRow+1;
topColumn = topColumn+1;    

% If any cell is brushed, the entire row must be shaded
if ~isvector(I)
   I = repmat(any(I,2),[1 size(I,2)]);
end
if ~isempty(subsstr)
    eval(['I = I' subsstr ';']);
end

% Build the brushing cache
nrows = min(size(I,1)-topRow+1,2*MINROWCOUNT);
ncols = min(size(I,2)-topColumn+1,2*MINCOLUMNCOUNT);
if ncols>0 && nrows>0
    outBooleanArray = I(topRow:topRow+nrows-1,topColumn:topColumn+ncols-1);
    numcols = size(outBooleanArray,2);
    outBooleanArray = outBooleanArray(:);
else
   outBooleanArray = [];
   numcols = 0;
end

% The top/left cell must always be returned - needed by Variable Editor code
topLeftVal = java.lang.Boolean(I(1,1));
jColor = java.awt.Color(thisColor(1),thisColor(2),thisColor(3));
    