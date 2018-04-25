function generateDefaultPropValueSyntaxNoOutput(hThis)

% Copyright 2003-2015 The MathWorks, Inc.

% Get handles
hFunc = getConstructor(hThis);
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
  
% Give this object a name if it doesn't 
% have one already
name = [];
if isempty(get(hThis,'Name'))
   hFunc = get(hThis,'Constructor');
   name = get(hFunc,'Name');
   if ~isempty(name)
      set(hThis,'Name',name); 
   end
end

% Add Input arguments
hPropList = get(hMomento,'PropertyObjects');
hObjectArg = codegen.codeargument('Value',hObj,'IsParameter',true);
hExtraFuncs = hFunc.generatePropValueList(hPropList, name, hObjectArg);
hThis.addPostConstructorFunction(hExtraFuncs);
