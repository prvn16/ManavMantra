classdef Launcher < rtw.connectivity.Launcher
    %LAUNCHER class for  PIL application
    %
    %   LAUNCHER(COMPONENTARGS,BUILDER) instantiates a LAUNCHER object that you can
    %   use to control starting and stopping of an application on the target
    %   processor. In this case the Debug Server Scripting (dss) utility which
    %   ships with EmbeddedCoder is used to download and
    %   run the executable.
    %
    %   See also RTW.CONNECTIVITY.LAUNCHER, RTWDEMO_CUSTOM_PIL
    
    %   Copyright 2013-2016 The MathWorks, Inc.
    
    %% Class properties
    properties
        Exe
        Ssh
        Scp
    end
    
    %% Class methods
    methods
        % constructor
        function this = Launcher(componentArgs, builder)
            narginchk(2, 2);
            % call super class constructor
            this@rtw.connectivity.Launcher(componentArgs, builder);
            ipAddress = 'cshei-tegra-ubuntu';
            username = 'ubuntu';
            password = 'ubuntu';
            port = 22;
            this.Ssh = matlabshared.internal.sshclient(ipAddress,username,password,port);
            this.Scp = matlabshared.internal.scpclient(ipAddress,username,password,port);
        end
        
        % destructor
        function delete(this)  %#ok<INUSD>
            % This method is called when an instance of this class is cleared from memory,
            % e.g. when the associated Simulink model is closed. You can use
            % this destructor method to close down any processes, e.g. an IDE or
            % debugger that was originally started by this class. If the
            % stopApplication method already performs this housekeeping at the
            % end of each on-target simulation run then it is not necessary to
            % insert any code in this destructor method. However, if the IDE or
            % debugger may be left open between successive on-target simulation
            % runs then it is recommended to insert code here to terminate that
            % application.
            % Kill the process that launched the embedded application
        end
        
        % Start the application
        function startApplication(this)
            % Get name of the executable file to download
            exeFullPath = this.getBuilder.getApplicationExecutable;
            [~,name,ext] = fileparts(exeFullPath);
            this.Exe = [name,ext];
            disp(DAStudio.message('arm_cortex_a:utils:LaunchPILAppMessage', this.Exe));

            % Load and run the executable
            connect(this.Ssh); % Connect here to accept RSA prompt
            
            % Load and run the executable
            try
                % Note only the 'fuser ..' command can fail here. If
                % it fails, this means there is no process grabbing port
                % 17725
                executeCommand(this.Ssh,...
                    ['killall -q ' this.Exe ';rm -f ' this.Exe '*; fuser 17725/tcp']);
            catch
            end
            
            putFile(this.Scp, exeFullPath, '.'); 
            cmd = ['chmod u+x ', this.Exe ';\`./' this.Exe ' &> ' this.Exe '.log&\` ; '];
            cmd = [cmd ' n=0; while [ ! \`pidof ' this.Exe '\` ] && [ $n -lt 10 ]; do n=$((n+1)); sleep 1; done; echo $n'];
            n = str2double(executeCommand(this.Ssh, cmd));
            if ~isnan(n) && n == 10
                disp(DAStudio.message('arm_cortex_a:utils:DiagnosticInformation'));
                cmd = ['ls -al ', this.Exe];
                disp(cmd);
                executeCommand(this.Ssh,cmd)
                cmd = ['cat ' this.Exe '.log'];
                disp(cmd);
                executeCommand(this.Ssh,cmd)
                error(message('arm_cortex_a:utils:PILApplicationDidNotStart'));
            end
        end
        
        % Stop the application
        function stopApplication(this)
            % Kill the process running on QEMU
            executeCommand(this.Ssh,['killall ' this.Exe ';rm -f ' this.Exe '* &']);
        end
    end
end