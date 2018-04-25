% Callback for uitabledemo

% Copyright 2008-2014 The MathWorks, Inc.

function AgeVerificationCallback(object, event)
if (event.Indices(2) == 2 && ...
      (event.NewData < 0 || event.NewData > 120))
   tableData = object.Data;
   tableData{event.Indices(1), event.Indices(2)} = event.PreviousData;
   object.Data = tableData;
   error('Age value must be between 0 and 120.')
end
