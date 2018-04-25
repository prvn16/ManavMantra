function varargout = fiaccel(varargin)
%FIACCEL Accelerate fixed-point code
%
%   FIACCEL accelerates Fixed-point code by generating a MEX function from
%   a MATLAB function and all the functions that this function calls.
%
%   You must specify the type of inputs the generated MEX function should
%   accept. The generated MEX function will be specialized to the class,
%   size, and complexity of the inputs.
%
%   The general syntax of the FIACCEL command is
%       fiaccel [-options] [files]
%
%   FILES:
%
%   Specify the name of the main (entry point) MATLAB file you want to
%   compile on the command line.  By default, for main file FUN.m, fiaccel 
%   generates a MEX function named FUN_mex in the current folder.
%
%   COMMON OPTIONS:
%
%   -args ARGS  Specify the types that the generated MEX function should
%               accept. ARGS is a cell array specifying the type of each
%               function argument. (Elements are converted to types using
%               coder.typeof.)
%
%   -o OUTPUT   Specify the name of the output.  FIACCEL adds a
%               platform-specific extension to this name.
%
%   -report     Generate a code generation report.
%
%   Examples:
%      %  Create a MEX function from a MATLAB function fun.m where the
%      %  first argument is a single scalar and the second argument is a
%      %  fixed-point scalar.
%      fiaccel fun -args { single(0), fi(0) }
%
%      % Create a MEX function from a MATLAB function fun.m where the first
%      % argument 'u' is fixed-point of variable size with maximum size 2x2,
%      % and the second argument 'k' has the constant value 42.
%      u = coder.typeof(fi(0),[2 2]);
%      k = coder.Constant(42);
%      fiaccel fun -args {u,k}
%
%      % Create a MEX function xbar from a MATLAB function bar.m which
%      % takes no inputs.
%      fiaccel -o xbar bar
%
%   OPTIONS:
%
%   -config CONFIG  Specify the configuration to use for this build.
%               CONFIG is a custom configuration object created by
%               coder.mexconfig.
%
%   -d DIR      Specify the output folder.  All generated files will be
%               placed in DIR.  By default, files are placed in
%               ./fiaccel/mex/<function>.  For example, when converting the
%               function FUN to a MEX function, the generated code will be
%               placed in ./fiaccel/mex/FUN.
%
%   -g          Enable debugging when invoking the C compiler.  By default,
%               the C compiler is called with full optimizations.
%
%   -globals GLOBALS  Specify types and initial values for global variables
%               used in the MATLAB files. For more information, refer to
%               the documentation.
%
%   -I PATH     Add files to the include path.  PATH is used to find MATLAB
%               files.  FIACCEL searches PATH before the MATLABPATH when
%               looking for MATLAB files.
%
%   -launchreport  Automatically launch the report.
%
%   -O OPTION   Controls FIACCEL optimizations.
%     Supported values for OPTION are:
%       enable:inline  - Enable function inlining (default)
%       disable:inline - Disable function inlining
%
%   See also mex, coder.mexconfig, coder.typeof and coder.Constant.
     
% Copyright 2010-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

for i = coder.internal.evalinArgs(varargin)
    try
        varargin{i} = evalin('caller', varargin{i});
    catch  %#ok Errors are handled later
    end
end

if nargout == 0
    coder.internal.fihelper(varargin{:});
else
    varargout{1} = coder.internal.fihelper(varargin{:});
end
