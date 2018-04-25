function alignRows(h,linkMgrFigureStruct,ax,mfile,fcnname)

% Force brushed rows for variables in the specified axes to have columns
% brushed if the corresponding graphic is in the axes and unbrushed
% otherwise. This method is needed to set the brushing array state
% when brushing linked plots in extend mode. It ensures that extend mode
% brushing can always clear existing brushing annotations in an axes. For example, if
% X is 100x2 and column 1 of X is plotted in axes1 and column 2 in axes2 -
% it will always be possible to use extend mode to clear brushing in axes 1
% even if points have been brushed in axes2.

% Find the graphics/variables in this axes
obj = findobj(double(linkMgrFigureStruct.LinkedGraphics),'-depth',0,'Parent',ax);
Igraphics = find(ismember(double(linkMgrFigureStruct.LinkedGraphics),obj));
varNames = linkMgrFigureStruct.VarNames(Igraphics,:);
varNames = unique(varNames(~cellfun('isempty',varNames)));

for k=1:length(varNames)
    % Create a temp array Ivar where all columns are brushed if any are
    Ivar = h.getBrushingProp(varNames{k},mfile,fcnname,'I');
    if ~isvector(Ivar)
        Ivar = Ivar(:,:);
        Ivar(any(Ivar,2),:) = true;
    end
    
    % Create a brushing array Itmp, with columns brushed if there is a
    % corresponding graphic in the axes and not brushed if there is not.
    Itmp = false(size(Ivar));
    for j=1:size(Igraphics,1)
        for col=1:3
            if strcmp(linkMgrFigureStruct.VarNames{Igraphics(j),col},varNames{k})
                substr = linkMgrFigureStruct.SubsStr{Igraphics(j),col};
                eval(['Itmp' substr ' = Ivar'  substr ';']);
            end
        end
    end
    
    h.setBrushingProp(varNames{k},mfile,fcnname,'I',Itmp);
end    
