%%%%%%%
% Copyright: 2017 The MathWorks, Inc.
% This method is used to invoke matlab.internal.addons.Explorer's sendMessage
% method from Java.
%%%%%%%
function sendMessageToExplorer(communicationMessage)
        matlab.internal.addons.Explorer.getInstance.sendMessage(communicationMessage);
end