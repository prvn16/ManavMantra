function openvar(name,array)
%OPENVAR Open workspace variable in tool for graphical editing
%   OPENVAR(NAME) edits the array in the base workspace whose name is given
%   in NAME.  NAME must contain a string.

%   Copyright 1984-2016 The MathWorks, Inc.


% Error handling.
matlab.desktop.vareditor.VariableEditor.checkAvailable();

matlab.desktop.vareditor.VariableEditor.checkVariableName(name);

if nargin > 1
    try
        % Workaround for tall arrays
        arrayEmpty = isempty(array);
        if ~islogical(logical(arrayEmpty))
            arrayEmpty = false;
        end
    catch
        % Assume empty if there's an error
        arrayEmpty = true;
    end
else
    arrayEmpty = true;
end

% Redirect to other commands based on data type.
if nargin > 1 && ~arrayEmpty

    % Get list of methods 
    methodList = {};
    isMCOS = false;
    if isobject(array) % MCOS object or overridden isobject
      % Methods can be hidden, so get the full methods list from the class
      hClass = metaclass(array);
      isMCOS = ~isempty(hClass);
      if isMCOS
          methodList = {hClass.MethodList.Name}';
      end
    end
    if ~isMCOS && (isa(array, 'handle') || isa(array, 'opaque'))
      % Just get the public list of methods
      methodList = methods(array);
    end
    
    % Check if object has its own editing utility.
    try %#ok<TRYNC>
        if ismember('dialog', methodList)
            if isa(array, 'Simulink.MCOSValueBaseObject')
                dialog(array, name, 'DLG_STANDALONE');
            else
                dialog(array);
            end
            return
        elseif ismember('getDialogSchema', methodList)
            if numel(array)==1
                DAStudio.Dialog(array, name, 'DLG_STANDALONE');
                return
            end
        elseif isa(array, 'handle')
            inspect(array);
            return
        end
    end
end

variable = com.mathworks.mlservices.WorkspaceVariableAdaptor(name);
com.mathworks.mlservices.MLArrayEditorServices.openVariable(variable);
