function varNames = getAllStructVarNames(h)

varNames = {};
for k=1:length(h.Figures)
    locVarNames = h.Figures(k).('VarNames');
    locVarNames = locVarNames(~cellfun('isempty',locVarNames));
    locVarNames = locVarNames(~cellfun('isempty',strfind(locVarNames,'.')));
    varNames = [varNames; locVarNames(:)];
end
varNames = unique(varNames(~cellfun('isempty',varNames)));