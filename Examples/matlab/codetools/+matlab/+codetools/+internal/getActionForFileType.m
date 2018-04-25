function customAction = getActionForFileType(fileName, action)
%Determine a customer action for a file.
%
%   customAction = matlab.codetools.internal.getActionForFileType(fileName, action) 
%   returns a custom action for the specified file and action. cusomAction
%   is a string that can be passed to feval. If no custom actions are found,
%   the result is an empty string.
%
%   Some actions allow the authors of filetypes to define a specific handler
%   for that file type. matlab.codetools.internal.getActionForFileType can be
%   used to determine if there is a custom action to take for a given file.
%
%   Example:
%
%       % Determine if there is a custom editor for a file.
%       customEditor = matlab.codetools.internal.getActionForFileType(fileName, 'edit');
% 
%       if ~isempty(customEditor)
%           feval(customEditor, fileName);
%           return
%       end

% Copyright 2014 The MathWorks, Inc.
customAction = '';

[~, ~, ext] = fileparts(fileName);

if isempty(ext)
    return;
end

customActionClass = ['matlab.codetools.internal.' action ext 'file'];
whichCustomAction = which(customActionClass);

if ~isempty(whichCustomAction)
    customAction = customActionClass;
end