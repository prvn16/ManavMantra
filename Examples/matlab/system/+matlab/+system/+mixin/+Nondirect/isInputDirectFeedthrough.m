% ISINPUTDIRECTFEEDTHROUGH(OBJ) Direct feedthrough status of an input
%   
%     [flag1,...,flagN] = isInputDirectFeedthrough(OBJ,u1,u2,...,uN)
%
%   indicates whether each input is a direct feedthrough input. If direct 
%   feedthrough is true, the output of the System object depends on the 
%   input values from the same time instant.  The inputs, u1,u2,...,uN,
%   must match the inputs to the output method.
%
%   If the System object supports code generation and it does not inherit 
%   from the Propagates mixin, Simulink can automatically infer the direct 
%   feedthrough settings from the System object MATLAB code.
%   If the System object supports code generation and inherits from the 
%   Propagates mixin, Simulink doesn't automatically infer direct feedthrough 
%   setting, and relies on isInputDirectFeedthroughImpl method.
%   If the System object does not support code generation, the default 
%   isInputDirectFeedthrough will return false (no directfeedthrough).
%
%   See also update, output
