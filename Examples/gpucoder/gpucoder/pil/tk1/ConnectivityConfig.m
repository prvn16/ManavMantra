classdef ConnectivityConfig < rtw.connectivity.Config
    %CONNECTIVITYCONFIG PIL connectivity configuration class
    %
    %   Copyright 2013-2016 The MathWorks, Inc.
    
    methods
        function this = ConnectivityConfig(args)
            appFwk = pil.TargetApplicationFramework(args);
            builder = rtw.connectivity.MakefileBuilder(args,appFwk,'.elf');
            launcher = pil.Launcher(args,builder);
            sharedLibExt = system_dependent('GetSharedLibExt');
            lib = ['libmwrtiostreamtcpip' sharedLibExt];
            communicator = rtw.connectivity.RtIOStreamHostCommunicator(args,launcher,lib);
            communicator.setInitCommsTimeout(30);
            communicator.setTimeoutRecvSecs(30);
            argList = {'-hostname','cshei-tegra-ubuntu','-client','1','-blocking','1','-port','17725'};
            communicator.setOpenRtIOStreamArgList(argList);
            this@rtw.connectivity.Config(args,builder,launcher,communicator);
            %Configure timer
            %timer = codertarget.arm_cortex_a.pil.profilingTimer(hCS);
            %this.setTimer(timer);
        end
    end
end
