function [hFrame, api] = createEmptyFrame(this, hParent)
%CREATEEMPTYFRAME Create an empty panel for "no indexing".
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.

%   Copyright 2005-2013 The MathWorks, Inc.
    
    % Create the components.
    hFrame = uipanel('Parent', hParent);
    
    % Create the API.
    api.reset = @reset;
    
    function reset(istruct)
    end
end

