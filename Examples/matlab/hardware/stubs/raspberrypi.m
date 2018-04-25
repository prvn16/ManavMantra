function varargout = raspberrypi(varargin)
    %RASPBERRYPI Access Raspberry Pi hardware.
    %
    % obj = RASPBERRYPI(DEVICEADDRESS, USERNAME, PASSWORD) creates a
    % RASPBERRYPI object connected to the Raspberry Pi hardware at
    % DEVICEADDRESS with login credentials USERNAME and PASSWORD. The
    % DEVICEADDRESS can be an IP address such as '192.168.0.10' or a
    % hostname such as 'raspberrypi-MJONES.foo.com'.
    %
    % obj = RASPBERRYPI() creates a RASPBERRYPI object connected
    % to a Raspberry Pi hardware using saved values for DEVICEADDRESS,
    % USERNAME and PASSWORD.
    %
    %
    %METHODS:
    %
    % output = SYSTEM(obj,command) executes the Linux command on the
    % Raspberry Pi hardware and returns the resulting output.
    %
    % LOADMODEL(obj,modelName) loads a previously compiled Simulink
    % model to the Raspberry Pi hardware.
    %
    % RUNMODEL(obj,modelName) runs a previously compiled Simulink
    % model on the Raspberry Pi hardware.
    %
    % STOPMODEL(obj,modelName) stops the execution of a Simulink model on
    % the Raspberry Pi hardware.
    %
    % [status, pid] = ISMODELRUNNING(obj,modelName) returns run status and
    % the process ID of a specified Simulink model. If the model is running
    % on the Raspberry Pi hardware the return value for status is true.
    % Otherwise, the return value for status is false.
    %
    % GETFILE(obj,remoteSource,localDestination) copies the remoteSource
    % on the Raspberry Pi hardware to the localDestination on the local
    % host computer. The input parameter, localDestination, is optional. If
    % not specified, the remoteSource is copied to the current directory.
    %
    % PUTFILE(obj,localSource,remoteDestination) copies the localSource
    % on the local host computer to the remoteDestination on the Raspberry
    % Pi hardware. The input parameter, remoteDestination, is optional.
    % If not specified, the remoteDestination is copied to the user's home
    % directory on the Raspberry Pi hardware.
    %
    % DELETEFILE(obj,remoteFile) deletes remoteFile on the Raspberry Pi
    % hardware.
    %
    % OPENSHELL(obj) launches a SSH terminal session. Once the terminal
    % session is started, you can execute commands on the Raspberry Pi
    % hardware interactively.
    %
    % STARTROSCORE(obj,catkinWs) launches roscore application on the
    % Raspberry Pi hardware using specified Catkin workspace with the
    % default port number 11311. 
    %
    % STARTROSCORE(obj,catkinWs,port) launches roscore application with
    % the specified Catkin workspace and port number.
    %
    % STOPROSCORE(obj) terminates roscore application running on the
    % Raspberry Pi hardware.
    %
    % RUNROSNODE(obj,modelName,catkinWs) runs the ROS
    % node generated from the given model on the Raspberry Pi hardware
    % using the specified Catkin workspace. The running node uses the
    % ROS master specified for simulation in Tools > Robot Operating System
    % > Configure Network Addresses GUI.
    %
    % RUNROSNODE(obj,modelName,catkinWs,rosMasterUri,rosIP) runs the ROS
    % node generated from the given model with specified ROS master and ROS
    % node IP.
    %
    % Examples:
    %
    %  r = raspberrypi;
    %  system(r,'ls -al ~')
    %
    %  lists the contents of the home directory for the current user on the
    %  Raspberry Pi hardware.
    %
    %  runModel(r,'raspberrypi_gettingstarted')
    %
    %  runs the model 'raspberrypi_gettingstarted' on the Raspberry Pi
    %  hardware. The model must be previously run on the Raspberry Pi
    %  hardware for this method to work properly.
    %
    %  getFile(r,'/home/debian/img0.dat')
    %
    %  copies the file 'img0.dat' in the '/home/debian' directory of the
    %  Raspberry Pi hardware to the current directory on the host
    %  computer.
    %
    %  putFile(r,'img0.dat','/home/debian')
    %
    %  copies the file 'img0.dat' in the current directory on the host
    %  computer to the '/home/debian' directory on the Raspberry Pi
    %  hardware.
    %
    %  openShell(r)
    %
    %  launches a PuTTY SSH terminal session. After logging into the Linux
    %  shell, you can execute interactive shell commands.
    
    
    % Copyright 2016 The MathWorks, Inc.
    
     
    varargout = {[]};

    % Check if the support package is installed.
    try
        fullpathToUtility = which('codertarget.raspi.internal.getSpPkgRootDir');
        if isempty(fullpathToUtility) 
            % Support package not installed - Error.
            error(getString(message('MATLAB:hwstubs:general:spkgNotInstalled', 'Simulink Raspberry Pi', 'RASPPI')));
        end
    catch e
        throwAsCaller(e);
    end
end