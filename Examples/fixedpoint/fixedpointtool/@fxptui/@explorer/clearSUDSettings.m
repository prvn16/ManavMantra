function clearSUDSettings(me)
% CLEARSUDSETTINGS Clear the Signal logging points and highlighting of the
% previously selected system under design. Only the signal logging points
% turned on by the tool will be reset.

% Copyright 2014 The MathWorks, Inc.

% remove highlighting of the node
treeNode = me.ConversionNode;
if ~isempty(treeNode)
    me.highlight(me.ConversionNode,[1 1 1]); % white
end

    
    



