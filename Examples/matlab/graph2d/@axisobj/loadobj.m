function B = loadobj(A)
%AXISOBJ/LOADOBJ Load axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 

if strcmp(class(A),'axisobj')
   B=A;
else % object definition has changed
   % or the parent class definition has changed?
   try
      A = rmfield(A,'Draggable');
      HGObj = A.scribehgobj;
      A = rmfield(A,'scribehgobj');
      B = class(A,'axisobj',HGObj);  
   catch err
      disp(err.message)
      warning(message('MATLAB:loadobj:IncompatibleFileVersion'));
   end

end
