%% Getting Started with Simulink(R) Coder(TM) 
% This model shows an implementation of a second-order physical system 
% called an ideal mass-spring-damper system. Components of the systems 
% equation are listed as mass, stiffness, and damping. You can use this model
% to generate code for real-time deployment of a continuous-time physical system.

%%

open_system('rtwdemo_secondOrderSystem');

%% Real-Time System Rapid Prototyping
% With Simulink(R) Coder(TM) you can generate C code from Simulink 
% diagrams, Stateflow charts, and MATLAB functions. The code generation
% process is a part of the V-model for system development. The process includes code 
% generation, code verification, and testing of the executable program in real-time.
% For rapid prototyping of a real-time application, typical tasks are:
%%
% * Configure the model for code generation
% * Check the model configuration for execution efficiency
% * Generate and view the C code
% * Create and run the executable of the generated code
% * Verify the execution results
% * Build the target executable
% * Run the external mode target program
% * Connect Simulink(R) to the external process for testing
% * Use signal monitoring and parameter tuning to further test your program
%
%% Real-Time Execution with Simulink External Mode
% To quickly run this model in external mode as an interface to the standalone
% executable:

%%
% # <matlab:model='rtwdemo_secondOrderSystem';%20open_system(model); Open> the |rtwdemo_secondOrderSystem| model.
% # Save the model to your working folder.
% # <matlab:openDialog(getActiveConfigSet(model)); Open> the Configuration Parameters
% dialog box and select the *Code Generation > Interface* pane.
% # Select *External mode*, and click *Apply*.
% # To build the model, in the Simulink Editor window, press *Ctrl+B*.
% # Open a command prompt window and run the executable: |rtwdemo_secondOrderSystem -tf
% inf|
% # From the Simulink Editor, select *Code > External Mode Control Panel*.
% # To establish a connection, on the External Model Control Panel, click *Connect*.
%
% In the scope, you can view the data from the external process. To test your application, 
% you can modify tunable parameters and monitor signals. For more information, see 
% <matlab:helpview([docroot,'/toolbox/rtw/helptargets.map'],'realtimeexecution_externalmode')
% Real-Time Execution with Simulink External Mode>.
%
% After you test the executable:
%%
% # On the *External Mode Control Panel*, click *Disconnect*.
% # In your command window, stop the process.
% # <matlab:bdclose(model); Close> the |rtwdemo_secondOrderSystem| model.
%
% For more information on how to generate code from a model, see the
% <matlab:helpview([docroot,'/toolbox/rtw/helptargets.map'],'simulinkcodergstutorials')
% Tutorials> in the _Getting Started with Simulink Coder_ documentation. 


