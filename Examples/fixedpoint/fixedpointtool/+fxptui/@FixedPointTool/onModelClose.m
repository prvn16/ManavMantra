function onModelClose(this)
% ONMODELCLOSE Clean up and close the window when the model is closed.

% Copyright 2017 The MathWorks, Inc.

if ~isempty(this.DataController)
    this.DataController.clearDatabase;
end
this.close;

end