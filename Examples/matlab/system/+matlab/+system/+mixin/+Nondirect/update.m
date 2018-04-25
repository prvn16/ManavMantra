% UPDATE(OBJ) Update System object states based on inputs
%   
%   update(OBJ,X) 
%
%   processes the object input data, X, to update the object states, 
%   for System object, OBJ.  The update method produces no outputs
%   
%   If a System object inherits from the matlab.system.mixin.Nondirect base
%   class the update method processes the object inputs to update the object
%   states according to the object algorithm. The number of input
%   arguments depends on the algorithm, and may depend also on one or more
%   property settings. The update method for some objects accepts 
%   fixed-point (fi) inputs.     
%          
%   The update method cannot be called before the output method.  
%          
%   See the object class help for information specific to the update method
%   for that System object.   
%
%   See also output, isInputDirectFeedthrough, step
 
      