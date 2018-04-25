% Copyright 2006-2012 The MathWorks, Inc.

classdef memmap_data_handle_holder < handle
   properties
       dataHandle = 0;
   end
   
   methods
       % ------------------------------------------------------------------
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%   Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function h = memmap_data_handle_holder(dh)
           h.dataHandle = dh;
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%   Destructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function delete(h)
           % Free the internal structure owned by this object.
           memmapfile.DeleteDataHandle(h.dataHandle);
       end
   end
end
