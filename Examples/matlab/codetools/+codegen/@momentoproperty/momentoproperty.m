classdef momentoproperty < matlab.mixin.SetGet & matlab.mixin.Copyable
% Copyright 2016 The MathWorks, Inc.

properties    
    DataTypeDescriptor@codegen.DataTypeDescriptor = codegen.DataTypeDescriptor.Auto
    Name 
    Value
    Object
    Ignore = false;    
    IsParameter = false;    
end
end  % classdef

