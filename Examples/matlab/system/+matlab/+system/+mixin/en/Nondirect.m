classdef Nondirect< matlab.system.mixin.NondirectCore
%matlab.system.mixin.Nondirect Mixin to control direct feedthrough
%   The Nondirect mixin is used to allow System objects to be used in 
%   feedback loops in Simulink.  If a System object's output does not 
%   directly depend on its input, use the Nondirect mixin to enable output 
%   and update methods to be used in addition to the step method.  The 
%   output method calculates outputs from states and/or inputs while the 
%   update method updates state values from inputs.  
%   
%   The Nondirect mixin is used in a System object in the MATLAB System
%   Block to break algebraic loops in Simulink by separating output
%   processing from update processing and for controlling direct feedthrough.  
%   If the System object supports code generation and it does not inherit 
%   from the Propagates mixin, Simulink can automatically infer the direct 
%   feedthrough settings from the System object MATLAB code.
%   If the System object supports code generation and inherits from the 
%   Propagates mixin, Simulink doesn't automatically infer direct feedthrough 
%   setting, and relies on isInputDirectFeedthroughImpl method.
%   If the System object does not support code generation, the default 
%   isInputDirectFeedthrough will return false (no directfeedthrough).
%
%   To use this mixin, subclass from the Nondirect class in addition 
%   to the matlab.System base class. Use the following syntax as the first
%   line of your class definition file,  where ObjectName is the name of
%   your object:
%   
%   classdef ObjectName < matlab.System &...
%       matlab.system.mixin.Nondirect

 
%   Copyright 2012-2014 The MathWorks, Inc.

    methods
        function out=Nondirect
            %matlab.system.mixin.Nondirect Mixin to control direct feedthrough
            %   The Nondirect mixin is used to allow System objects to be used in 
            %   feedback loops in Simulink.  If a System object's output does not 
            %   directly depend on its input, use the Nondirect mixin to enable output 
            %   and update methods to be used in addition to the step method.  The 
            %   output method calculates outputs from states and/or inputs while the 
            %   update method updates state values from inputs.  
            %   
            %   The Nondirect mixin is used in a System object in the MATLAB System
            %   Block to break algebraic loops in Simulink by separating output
            %   processing from update processing and for controlling direct feedthrough.  
            %   If the System object supports code generation and it does not inherit 
            %   from the Propagates mixin, Simulink can automatically infer the direct 
            %   feedthrough settings from the System object MATLAB code.
            %   If the System object supports code generation and inherits from the 
            %   Propagates mixin, Simulink doesn't automatically infer direct feedthrough 
            %   setting, and relies on isInputDirectFeedthroughImpl method.
            %   If the System object does not support code generation, the default 
            %   isInputDirectFeedthrough will return false (no directfeedthrough).
            %
            %   To use this mixin, subclass from the Nondirect class in addition 
            %   to the matlab.System base class. Use the following syntax as the first
            %   line of your class definition file,  where ObjectName is the name of
            %   your object:
            %   
            %   classdef ObjectName < matlab.System &...
            %       matlab.system.mixin.Nondirect
        end

    end
    methods (Abstract)
    end
end
