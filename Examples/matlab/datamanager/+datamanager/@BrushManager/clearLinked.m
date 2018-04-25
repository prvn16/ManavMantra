function clearLinked(h,Ifig,ax,mfile,fcnname)

% Clears linked brushing in the specified axes

linkMgr  = datamanager.LinkplotManager.getInstance();
if isempty(linkMgr.Figures)
    return;
end

% Get the variables in this axes
if ~isnumeric(Ifig)
    Ifig = find([linkMgr.Figures.('Figure')]==Ifig);
end
gObj = double(linkMgr.Figures(Ifig).LinkedGraphics);
I = cellfun(@(x) x==double(ax),get(gObj,{'Parent'}));
varNames = linkMgr.Figures(Ifig).VarNames(I,:);
varNames = unique(varNames(~cellfun('isempty',varNames)));

%Clear the brushing array by variable names
datamanager.clearLinked(h,varNames,mfile,fcnname);