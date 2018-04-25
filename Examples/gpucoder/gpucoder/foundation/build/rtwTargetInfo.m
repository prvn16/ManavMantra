function rtwTargetInfo(tr)
%RTWTARGETINFO Target info callback

% Copyright 2012-2016 The MathWorks, Inc.

    tr.registerTargetInfo(@loc_createToolchain);
end

% -------------------------------------------------------------------------
% Create the ToolchainInfoRegistry entries
% -------------------------------------------------------------------------
function config = loc_createToolchain

config = coder.make.ToolchainInfoRegistry; % initialize
toolsDir = fullfile(matlabroot, 'toolbox', 'gpucoder', 'gpucoder', 'foundation', 'build', 'tools');
archName = computer('arch');

% -----------------------------------
% NVIDIA CUDA Toolchains
% -----------------------------------
if strcmpi(archName, 'glnxa64')

    % NVIDIA CUDA 8.0
    config(end+1).Name              = 'NVIDIA CUDA | gmake (64-bit Linux)';
    config(end).Alias               = {'NVIDIA CUDA  | gmake (64-bit Linux)'};
    config(end).FileName            = fullfile(toolsDir, 'cuda_glnxa64_tc_gmake_glnxa64_vall.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'glnxa64'};

    % NVIDIA CUDA Jetson TK1
    config(end+1).Name              = 'NVIDIA CUDA for Jetson Tegra K1 v6.5 | gmake (64-bit Linux)';
    config(end).FileName            = fullfile(toolsDir, 'cuda_tk1_arm32_tc_gmake_glnxa64_v6.5.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'glnxa64'};

    % NVIDIA CUDA Jetson TX1
    config(end+1).Name              = 'NVIDIA CUDA for Jetson Tegra X1 | gmake (64-bit Linux)';
    config(end).Alias               = {'NVIDIA CUDA for Jetson Tegra X1 v7.0 | gmake (64-bit Linux)'};
    config(end).FileName            = fullfile(toolsDir, 'cuda_tx1_aarch64_tc_gmake_glnxa64_v.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'glnxa64'};

    % NVIDIA CUDA Jetson TX2
    config(end+1).Name              = 'NVIDIA CUDA for Jetson Tegra X2 | gmake (64-bit Linux)';
    config(end).Alias               = {'NVIDIA CUDA for Jetson Tegra X2 v8.0 | gmake (64-bit Linux)'};
    config(end).FileName            = fullfile(toolsDir, 'cuda_tx2_aarch64_tc_gmake_glnxa64_v.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'glnxa64'};

elseif (strcmpi(archName, 'win64'))

    % NVIDIA CUDA with Visual Studio 15.0
    config(end+1).Name              = 'NVIDIA CUDA (w/Microsoft Visual C++ 2017) | nmake (64-bit Windows)';
    config(end).Alias               = {'NVIDIA CUDA  (w/Microsoft Visual C++ 2017) | gmake (64-bit Windows)'};
    config(end).FileName            = fullfile(toolsDir, 'cuda_win64_tc_nmake_win64_v15.0.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'win64'};

    % NVIDIA CUDA with Visual Studio 14.0
    config(end+1).Name              = 'NVIDIA CUDA (w/Microsoft Visual C++ 2015) | nmake (64-bit Windows)';
    config(end).Alias               = {'NVIDIA CUDA  (w/Microsoft Visual C++ 2015) | gmake (64-bit Windows)'};
    config(end).FileName            = fullfile(toolsDir, 'cuda_win64_tc_nmake_win64_v14.0.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'win64'};

    % NVIDIA CUDA with Visual Studio 12.0
    config(end+1).Name              = 'NVIDIA CUDA (w/Microsoft Visual C++ 2013) | nmake (64-bit Windows)';
    config(end).Alias               = {'NVIDIA CUDA  (w/Microsoft Visual C++ 2013) | gmake (64-bit Windows)'};
    config(end).FileName            = fullfile(toolsDir, 'cuda_win64_tc_nmake_win64_v12.0.mat');
    config(end).TargetHWDeviceType  = {'*'};
    config(end).Platform            = {'win64'};

end

% -------------------------------------------------------------------------
% ADDING A NEW ENTRY:
% 1. Copy the commented block of code below
% 2. Paste it at the bottom of the list above
% 3. Uncomment it
% 4. Fill out the required information
% -------------------------------------------------------------------------
% config(end+1)                   = coder.make.ToolchainInfoRegistry;
% config(end).Name                = <put the 'Name' property of the toolchain here>;
% config(end).FileName            = <insert the MAT file here with complete path>;
% config(end).TargetHWDeviceType  = {'*'};
% -------------------------------------------------------------------------
end

% LocalWords:  Toolchain Toolchains nmake vc SDK gmake maci Sybase watcom
% LocalWords:  toolchain
