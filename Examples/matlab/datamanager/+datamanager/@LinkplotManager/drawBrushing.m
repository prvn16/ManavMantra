function drawBrushing(h,figId,mfile,fcnname)

% Draws the brushing arrays for all the variables contained in the
% specified figure.

% Find the figure struct
if isempty(h.Figures)
    return
end
if ~isnumeric(figId)
    figId = find([h.Figures.('Figure')]==figId);
end
figStruct = h.Figures(figId);

% Draw the brushing arrays
brushMgr = datamanager.BrushManager.getInstance();
varNames = figStruct.VarNames;
varNames = varNames(~cellfun('isempty',varNames));
newVarNames = unique(varNames);
for k=1:length(newVarNames)
    brushMgr.draw(newVarNames{k},mfile,fcnname);
end