%SETMCRUSERDATA Store MCR instance-specific data.
%   SETMCRUSERDATA(KEY, VALUE) Associate the MATLAB data VALUE with the 
%      string KEY in the current MCR instance. If there is already a 
%      value associated with KEY, overwrite it. This function is 
%      available both in MATLAB and in deployed applications created with 
%      the MATLAB Compiler or MATLAB Compiler SDK.  
%
%      The key must be a string. The value stored may be any valid 
%      MATLAB data type, including matrices, cell arrays and Java objects.
%
%      Example (storing a cell array):
%
%          value = {3.14159, 'March 14th is PI day'};
%          setmcruserdata('PI_Data', value);
%
%      SETMCRUSERDATA makes a copy of the value before storing it. Changing
%      the value in the workspace after storing it will not affect the
%      stored value. To modify the stored value, retrieve it with 
%      GETMCRUSERDATA, modify the retrieved value, then place it back in 
%      data store with SETMCRUSERDATA.
%
%          value = getmcruserdata('PI_Data');
%          value{end+1} = 'Apple Pie';
%          setmcruserdata('PI_Day', value);
%
%   See also GETMCRUSERDATA.

%   Copyright 2008, The MathWorks, Inc.
%   Built-in function.

