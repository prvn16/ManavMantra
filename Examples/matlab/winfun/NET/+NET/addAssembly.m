%NET.addAssembly makes a .NET assembly visible to MATLAB.
%  A = NET.addAssembly(ASSEMBLY) 
%  makes an assembly visible to MATLAB and returns and instance of
%  NET.Assembly class.
%
%  ASSEMBLY is one of the following:
%  -string that represents name of the assembly. 
%  -string that represents full path of the assembly. 
%  -an instance of System.Reflection.AssemblyName class.
%
%  Returns a class NET.Assembly.  NET.Assembly class has the following
%  properties:
%
%   AssemblyHandle:	An instance of System.Reflection.Assembly class of the
%                   added assembly.
%   Classes:        Mx1 cell array of class names of the added assembly.
%   Enums:          Mx1 cell array of enums of the added assembly. 
%   Structures:     Mx1 cell array of structures of the added assembly. 
%   GenericTypes:   Mx1 cell array of generic types of the added assembly.
%   Interfaces:     Mx1 cell array of interface names of the added assembly. 
%   Delegates:      Mx1 cell array of delegates of the added assembly.  
%
%  Examples:
%  Add reference to a private assembly:
%  asm = NET.addAssembly('c:\work\MLDotNetTest.dll');
%
%  Add reference to a GAC assembly:
%  asm = NET.addAssembly('System.Windows.Forms')
%
%   NET.Assembly  handle
%   Package: NET
% 
% Properties for class NET.Assembly:
% 
%     AssemblyHandle
%     Classes
%     Structures
%     Enums
%     GenericTypes
%     Interfaces
%     Delegates
%
%  NOTES:
%       Do not specify an extension for GAC assemblies.
%       Specify the full path for private assemblies.
%       mscorlib and System assemblies are loaded by default.

% Copyright 2008 The MathWorks, Inc.
%  $Date $
