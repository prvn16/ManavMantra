function varargout = gpucoder(varargin) %#ok


%GPUCODER Launch a code generation project
%
%   GPUCODER opens a dialog from which you can create a new code generation
%   project or open an existing one.
%
%   GPUCODER PROJECT opens the existing project file PROJECT.
%
%   GPUCODER -new PROJECT creates a new GPU Coder project named PROJECT. 
%
%
%   GPUCODER -script SCRIPT -tocode PROJECT converts the existing project
%   PROJECT to a MATLAB script. The script is written to the file SCRIPT.
%   The file SCRIPT is overwritten if it already exists.
%
%   GPUCODER -build PROJECT builds the existing project PROJECT.
%
%   Alternatively, you can generate code from the command line
%   using the CODEGEN command.
%
%   See also codegen.

% Copyright 1984-2017 The MathWorks, Inc.

    try
        coder('-gpu', varargin{:});
        %com.mathworks.toolbox.coder.app.CoderApp.runGpuCoder();
    catch me
        me.throwAsCaller();
    end
end



