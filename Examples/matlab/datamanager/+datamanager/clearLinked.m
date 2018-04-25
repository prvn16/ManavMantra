function clearLinked(h,varNames,mfile,fcnname)

% Used when called from the Variable Editor.
if nargin<=2
    [mfile,fcnname] = datamanager.getWorkspace(1);
end
if isempty(h)
    h = datamanager.BrushManager.getInstance();
end

%Clear the brushing array by variable names
for k=1:length(varNames)
    Iclear = h.getBrushingProp(varNames{k},mfile,fcnname,'I');
    h.setBrushingProp(varNames{k},mfile,fcnname,'I',false(size(Iclear)));
end
for k=1:length(varNames)
    h.draw(varNames{k},mfile,fcnname);
end