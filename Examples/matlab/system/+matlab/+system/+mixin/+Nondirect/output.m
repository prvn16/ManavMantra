% OUTPUT(OBJ) Calculate outputs from inputs or internal states of System object
%   
%   Y = output(OBJ,X) processes the object state and input data, X, to 
%   produce the output, for System object, OBJ.
%   
%   [Y1,...,YN] = output(OBJ,X) Produces N outputs.
%   
%   If a System object inherits from the matlab.system.mixin.Nondirect base
%   class the output method processes the object states and the direct 
%   feedthrough inputs to create the output according to the object 
%   algorithm. The number of input and output arguments depends on the 
%   algorithm and may depend also on one or more property settings. The 
%   output method for some objects accepts fixed-point (fi) inputs.     
%          
%   Calling output on an object locks the object. When the object is
%   locked, you cannot change non-tunable properties or any input
%   characteristics (size, data type or complexity) without first calling
%   the release method to unlock the object.
%          
%   See the object class help for information specific to the output method
%   for that System object.   
%
%   See also update, isInputDirectFeedthrough, step
      
      