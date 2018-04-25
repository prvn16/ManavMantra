classdef CompilerConfigurationDetails
% CompilerConfigurationDetails class encapsulates detailed information used
% by MEX.
%
% See also MEX MEX.getCompilerConfigurations 

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2013/07/23 01:17:19 $

    properties( SetAccess=private )
        CompilerExecutable
    end
    
    properties
        CompilerFlags
    end %Writeable properties

    properties( SetAccess=private )
        OptimizationFlags
        DebugFlags
        LinkerExecutable
        LinkerFlags
        LinkerOptimizationFlags
        LinkerDebugFlags
        SetEnv
        CommandLineShell
        CommandLineShellArg
    end %Documented properties
    

    properties ( Hidden=true)
        SystemDetails
    end %Undocumeted Properties
    
    methods
        function CCD = CompilerConfigurationDetails(detailsStruct)
        %
        
        % CompilerConfigurationDetails constructor
        %   CompilerConfigurationDetails(detailsStruct) creates
        %   CompilerConfigurationDetails from detailsStruct that contains
        %   the values of its properties.
        %
        %   See help for MEX.getCompilerConfigurations for more information.
        %
        % See also MEX MEX.getCompilerConfigurations
        % MEX.CompilerConfiguration MEX.CompilerConfigurationDetails
        
        CCD.CompilerExecutable = detailsStruct.CompilerExecutable;
        CCD.CompilerFlags = detailsStruct.CompilerFlags;
        CCD.OptimizationFlags = detailsStruct.OptimizationFlags;
        CCD.DebugFlags = detailsStruct.DebugFlags;
        CCD.LinkerExecutable = detailsStruct.LinkerExecutable;
        CCD.LinkerFlags = detailsStruct.LinkerFlags;
        CCD.LinkerOptimizationFlags = detailsStruct.LinkerOptimizationFlags;
        CCD.LinkerDebugFlags = detailsStruct.LinkerDebugFlags;
        [CCD.SetEnv] = deal(detailsStruct.SetEnv);
        [CCD.CommandLineShell] = deal(detailsStruct.CommandLineShell);
        [CCD.CommandLineShellArg] = deal(detailsStruct.CommandLineShellArg);

        if ispc %for now system details are pc only
            CCD.SystemDetails.SystemPath = detailsStruct.SystemDetails.SystemPath;
            CCD.SystemDetails.LibraryPath = detailsStruct.SystemDetails.LibraryPath;
            CCD.SystemDetails.IncludePath = detailsStruct.SystemDetails.IncludePath;

            CCD.SystemDetails.TargetArch = detailsStruct.SystemDetails.TargetArch;
            CCD.SystemDetails.RenameObjectFlag = detailsStruct.SystemDetails.RenameObjectFlag;
            CCD.SystemDetails.LinkLibraryLocation = detailsStruct.SystemDetails.LinkLibraryLocation;
            %LINK_FILE
            %LINK_LIB
            CCD.SystemDetails.LinkOutputFlagAndDLLName = detailsStruct.SystemDetails.LinkOutputFlagAndDLLName;
            %RSP_FILE_INDICATOR
            %RC_COMPILER
            %RC_LINKER
            if isfield(detailsStruct.SystemDetails,'POSTLINK_CMDS')
                CCD.SystemDetails.POSTLINK_CMDS = detailsStruct.SystemDetails.POSTLINK_CMDS;
                postLinkCommandNumber = 1;
                while isfield(detailsStruct.SystemDetails,['POSTLINK_CMDS' num2str(postLinkCommandNumber)])
                    fieldName = (['POSTLINK_CMDS' num2str(postLinkCommandNumber)]);
                    CCD.SystemDetails.((fieldName)) = detailsStruct.SystemDetails.(fieldName);
                    postLinkCommandNumber = postLinkCommandNumber+1;
                end        
            end
        end
        end
    end %Methods

end %Classdef