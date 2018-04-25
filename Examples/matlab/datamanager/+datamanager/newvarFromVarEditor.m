function newvarFromVarEditor(varName)

% Disambiguate variables in linked plots when creating new variables from
% brushing annotations.

% Copyright 2008-2011 The MathWorks, Inc.

% Build and show Disambiguation dialog
dt = com.mathworks.mde.desk.MLDesktop.getInstance;
hostFrame = dt.getContainingFrame(dt.getClient(varName,'Variable Editor'));
[mfile,fcnname] = datamanager.getWorkspace(1);
dlg = javaObjectEDT('com.mathworks.page.datamgr.brushing.NewVarVariableDisambiguationDialog',...
        hostFrame);


% Specify callbacks
set(handle(dlg.getOKButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg varName mfile fcnname});
set(handle(dlg.getVariableComboBox.getEditor,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg  varName mfile fcnname});    

awtinvoke(dlg,'show()');


function localOK(es,ed,dlg,varName,mfile,fcnname) %#ok<INUSL>

newvarName = char(dlg.getVarName);
if isempty(newvarName) || ~isvarname(newvarName)
    javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane',...
        dlg,getString(message('MATLAB:datamanager:newvarFromVarEditor:InvalidOrEmptyVariableName')), 'MATLAB',...
        javax.swing.JOptionPane.ERROR_MESSAGE);
    return
end

h = datamanager.BrushManager.getInstance();
I = h.getBrushingProp(varName,mfile,fcnname,'I');
varValue = evalin('caller',varName);
if isvector(varValue)
    assignin('caller',newvarName,varValue(I));
else
    assignin('caller',newvarName,varValue(any(I,2),:));
end

awtinvoke(dlg,'hide()');


    