%% Getting Started with Embedded Coder
% This model shows an implementation of a roll axis autopilot
% control system, that is designed for code generation.

% Copyright 1990-2015 The MathWorks, Inc.

%% About the Model
% This model represents a basic roll axis autopilot with two operating
% modes: roll attitude hold and heading hold. The mode logic for these
% modes is external to this model. The model architecture represents the
% heading hold mode and basic roll attitude function as atomic subsystems.
%
% The roll attitude control function is a PID controller that uses roll
% attitude and roll rate feedback to produce an aileron command. The input
% to the controller is either a basic roll angle reference or a roll
% command to track the desired heading. The model is as follows:

open_system('rtwdemo_roll');

%% Subsystem |RollAngleReference|
% The basic roll angle reference calculation is implemented as
% the subsystem |RollAngleReference|. Embedded Coder(R) inlines this
% calculation directly into the main function for |rtwdemo_roll|.

open_system('rtwdemo_roll/RollAngleReference');

%% Subsystem |HeadingMode|
% The subsystem |HeadingMode| computes the roll command to track the desired heading.

close_system('rtwdemo_roll/RollAngleReference');
open_system('rtwdemo_heading');

%% Subsystem |BasicRollMode|
% The subsystem |BasicRollMode| computes the roll attitude control function (PID). 

close_system('rtwdemo_heading');
open_system('rtwdemo_attitude');

%% Generate Code for the Model
% The model is preconfigured to generate code using Embedded Coder. To
% generate code using Simulink Coder only, reconfigure the model or at the
% command prompt type
% |rtwconfiguredemo('rtwdemo_roll','GRT')|
%%
% In your system temporary folder, create a temporary folder for the build process.
currentDir = pwd;
[~,cgDir] = rtwdemodir();
%%
% Generate code.
rtwbuild('rtwdemo_roll');

%%
% You can view the entire generated code in a detailed HTML report, with
% bi-directional traceability between model and code.

web(fullfile(cgDir,'rtwdemo_roll_ert_rtw','html','rtwdemo_roll_codegen_rpt.html'))

%%
% Close models and return to previous working folder.

close_system('rtwdemo_roll',0)
close_system('rtwdemo_attitude',0)
close_system('rtwdemo_heading',0)

cd(currentDir);
% rtwdemoclean;

%% Embedded Coder Getting Started Tutorials
% For more information on generating code with Embedded Coder, see the 
% <matlab:helpview([docroot,'/toolbox/ecoder/helptargets.map'],'embeddedcodergstutorials') 
% Tutorials> in the _Getting Started with Embedded Coder_ documentation.

