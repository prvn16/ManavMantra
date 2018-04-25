%COPY    Copy MATLAB array of handle objects. 
%   B = COPY(H) copies each element in the array of handles H to the new
%   array of handles B.  
%
%   The COPY method does not copy dependent properties.  MATLAB does not 
%   call the COPY method recursively on any handles contained in propety
%   values.  MATLAB does not call the class constructor or property set 
%   methods during the copy operation. 
%                                                                           
%   B has the same number of elements and same size as H.  B is the same 
%   class as H.  If H is empty, B is also empty.  If H is heterogeneous, B 
%   is also heterogeneous. 
%
%   If H contains deleted handles, COPY creates deleted handles of 
%   the same class in B.
%
%   Dynamic properties and listeners associated with objects in H are not
%   copied to objects in B.  You can call COPY inside the DELETE method of 
%   your class. 
%
%   COPY is a sealed and public method in class matlab.mixin.Copyable.
%   
%   See also matlab.mixin.Copyable, copyElement, HANDLE
 
%   Copyright 2010-2013 The MathWorks, Inc.
%   Built-in function.
