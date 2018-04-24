%% Generate a Main Program for Deployment to a Bare Board Target (No Operating System)
% This model shows the *Generate an example main program* feature of Embedded Coder(R).  
% The model is configured to generate a main program suitable for deployment on a bare-board 
% target (one with no operating system).  Alternatively, you can configure the model to generate 
% an example main program for deployment on a VxWorks(R) operating system target.  
% The example |ert_main.c| that is generated for the model shows how to deploy the code.
% 
% You can customize a generated main program by using the Embedded Coder *File customization 
% template* which is located on the *Code Generation > Templates* pane.  
% See the Embedded Coder documentation for a description of this feature.
%% Open Example Model
% Open the example model |rtwdemo_examplemain|.

% Copyright 2015 The MathWorks, Inc.

open_system('rtwdemo_examplemain');
%% Instructions
% To select the *Generate an example main program* option,
%
% # From the menu bar, choose *Simulation > Model Configuration Parameters*.
% # Select the *Code Generation > Templates* pane.
% # Select *Generate an example main program*.
% # Configure *Target operating system*.