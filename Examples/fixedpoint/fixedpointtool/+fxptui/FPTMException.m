
%   Copyright 2013 The MathWorks, Inc.

classdef FPTMException < MException
    
   properties (SetAccess = private, GetAccess = private)
       ObjectHandle = []; %Handle to the block that caused the error
   end
   
   methods
       function this = FPTMException(ID, message, objHandle)
           this@MException(ID, message);
           if nargin > 2 && ~isempty(objHandle)
               this.ObjectHandle = objHandle;
           else
               % this is the default block diagram
               this.ObjectHandle = 0;
           end
       end
       
       function sourceName = getSource(this)
           objHandle = this.getObject;
           if objHandle == 0
               sourceName = 'Unknown';               
           else
               sourceName = get_param(objHandle,'Name');
           end
       end
       
       function objHandle = getObject(this)
           
           if isa(this.ObjectHandle,'DAStudio.Object')
               this.ObjectHandle = this.ObjectHandle.Handle;
           end           
           
           % Verify the validity of the object handle.  We have seen
           % instances of this being no longer valid when a replacement
           % model is created that cannot be updated.
           try
               get_param(this.ObjectHandle,'Object');
           catch ME %#ok<NASGU>
               this.ObjectHandle = 0;
           end
           
           objHandle = this.ObjectHandle;
       end
   end
end
