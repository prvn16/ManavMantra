function tabgroup = showcaseBuildTabGroupMPCDesigner(app)
    % Build the TabGroup for the MPC Designer app showcase.

    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    import matlab.ui.internal.toolstrip.*
    % tab group
    tabgroup = TabGroup();
    % tabs
    tabHome = Tab('MPC Designer');
    tabHome.Tag = 'tabHome';
    tabTune = Tab('Tune');
    tabTune.Tag = 'tabTune';
    % home tab
    createSession(tabHome, app);
    createStructure(tabHome, app);
    createScenario(tabHome, app.Figure1, app.Figure2);
    createResult(tabHome, app);
    % tune tab
    createGeneral(tabTune);
    createHorizon(tabTune);
    createConstraintWeightEstimation(tabTune);
    createTuning(tabTune, app.Figure1, app.Figure2);
    createAnalysis(tabTune);
    % assemble
    tabgroup.add(tabHome);
    tabgroup.add(tabTune);
end

function createSession(tab, app)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    % create section
    section = Section('session');
    section.Tag = 'SessionSection';
    % create column
    column = Column();
    % add open session push button
    OpenSessionIcon = Icon([iconpath 'OpenSession.png']);
    OpenSessionButton = Button('Open Session',OpenSessionIcon);
    OpenSessionButton.Tag = 'OpenSessionButton';
    OpenSessionButton.Description = 'Open a saved MPC design session'; 
    % add save session push button
    SaveSessionIcon = Icon([iconpath 'SaveSession.png']);
    SaveSessionButton = Button('Save Session',SaveSessionIcon);
    SaveSessionButton.Tag = 'SaveSessionButton';
    SaveSessionButton.Description = 'Save current MPC design into a session for future use'; 
    % assemble
    add(tab,section);
    add(section, column);
    add(column,OpenSessionButton);
    add(column,SaveSessionButton);
    % add callback
    OpenSessionButton.ButtonPushedFcn = @(x,y) localOpenDialog(x,y,app,OpenSessionButton);
    SaveSessionButton.ButtonPushedFcn = @(x,y) localOpenDialog(x,y,app,SaveSessionButton);
end

function createStructure(tab, app)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    % create section
    section = Section('Structure');
    section.Tag = 'StructureSection';
    % create column
    column1 = Column();
    column2 = Column();
    column3 = Column();
    % add import plant push button
    ImportPlantIcon = Icon([iconpath 'ImportPlant.png']);
    ImportPlantButton = Button(sprintf('%s\n%s','Import','Plant'),ImportPlantIcon);            
    ImportPlantButton.Tag = 'ImportPlantButton';
    ImportPlantButton.Description = 'Import a LTI plant model from base workspace'; 
    % add import controller push button
    ImportControllerIcon = Icon([iconpath 'ImportController.png']);
    ImportControllerButton = Button(sprintf('%s\n%s','Import','Controller'),ImportControllerIcon);            
    ImportControllerButton.Tag = 'ImportControllerButton';
    ImportControllerButton.Description = 'Import an MPC controller from base workspace'; 
    % add specify i/o push button
    IOConfigurationIcon = Icon([iconpath 'IOChannel.png']);
    IOConfigurationButton = Button(sprintf('%s\n%s','I/O','Channels'),IOConfigurationIcon);            
    IOConfigurationButton.Tag = 'IOConfigurationButton';
    IOConfigurationButton.Description = 'Specify properties for each plant input and output channel'; 
    % assemble
    add(tab,section);
    add(section, column1);
    add(column1,ImportPlantButton);
    add(section, column2);
    add(column2,ImportControllerButton);
    add(section, column3);
    add(column3,IOConfigurationButton);
    % add callback
    ImportPlantButton.ButtonPushedFcn = @(x,y) localOpenDialog(x,y,app,ImportPlantButton);
    addlistener(ImportPlantButton, 'ButtonPushed', @(x,y) disp('Import Plant Button Clicked!'));
    ImportControllerButton.ButtonPushedFcn = @(x,y) localOpenDialog(x,y,app,ImportControllerButton);
    addlistener(ImportControllerButton, 'ButtonPushed', @(x,y) disp('Import Controller Button Clicked!'));
    IOConfigurationButton.ButtonPushedFcn = @(x,y) localOpenDialog(x,y,app,IOConfigurationButton);
    addlistener(IOConfigurationButton, 'ButtonPushed', @(x,y) disp('I/O Configuration Button Clicked!'));
end

function createScenario(tab, fig1, fig2)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    % create section
    section = Section('Scenario');
    section.Tag = 'ScenarioSection';
    % create column
    column = Column();
    % add plot scenario dropdown button
    PlotScenarioIcon = Icon([iconpath 'PlotScenario.png']);
    PlotScenarioButton = DropDownButton(sprintf('%s\n%s','Plot','Scenario'),PlotScenarioIcon);            
    PlotScenarioButton.Tag = 'PlotScenarioButton';
    PlotScenarioButton.Description = 'Create and plot a simulation scenario'; 
    % assemble
    add(tab,section);
    add(section, column);
    add(column,PlotScenarioButton);
    % add callback
    PlotScenarioButton.DynamicPopupFcn = @(x, y) localBuildDynamicPopupForPlot(x, y, fig1, fig2);
end

function createResult(tab, app)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    % create section
    section = Section('Result');
    section.Tag = 'ResultSection';
    % create column
    column1 = Column();
    column2 = Column();
    % add compare dropdown button
    CompareControllerIcon = Icon([iconpath 'CompareControllers.png']);
    CompareControllerButton = DropDownButton(sprintf('%s\n%s','Compare','Controllers'),CompareControllerIcon);            
    CompareControllerButton.Tag = 'CompareControllerButton';
    CompareControllerButton.Description = 'Compare MPC controllers in all simulation scenarios'; 
    % add export dropdown button
    ExportControllerIcon = Icon([iconpath 'ExportAll.png']);
    ExportControllerButton = SplitButton(sprintf('%s\n%s','Export','Controllers'),ExportControllerIcon);            
    ExportControllerButton.Tag = 'ExportControllerButton';
    ExportControllerButton.Description = 'Export MPC controllers to base workspace';
    % create popup
    popup = PopupList();
    item1 = ListItem('Export Controllers',Icon([iconpath 'ExportAll.png']));
    item1.Tag = 'item1';
    item1.Description = 'Export selected MPC controllers to MATLAB workspace';
    item2 = ListItem('Generate Script',Icon([iconpath 'GenerateScript.png']));
    item2.Tag = 'item2';
    item2.Description = 'Generate MATLAB script to reproduce controller design at command line';
    popup.add(item1);
    popup.add(item2);
    ExportControllerButton.Popup = popup;
    % assemble
    add(tab,section);
    add(section, column1);
    add(column1,CompareControllerButton);
    add(section, column2);
    add(column2,ExportControllerButton);
    % add callback
    CompareControllerButton.DynamicPopupFcn = @localBuildDynamicPopupForCompare;
    ExportControllerButton.ButtonPushedFcn = @(x,y) localOpenDialog(x,y,app,ExportControllerButton);
    addlistener(ExportControllerButton, 'ButtonPushed', @(x,y) disp('Export Controller Button Clicked!'));
    addlistener(item1, 'ItemPushed', @(x,y) disp('Import Controller Item Clicked!'));
    addlistener(item2, 'ItemPushed', @(x,y) disp('Generate Script Item Clicked!'));
end

function createGeneral(tab)
    import matlab.ui.internal.toolstrip.*
    % create section
    section = Section('Controller');
    section.Tag = 'GeneralSection';
    % create column
    column1 = Column('HorizontalAlignment','right');
    column2 = Column('Width',60);
    % create labels
    ControllerLabel = Label('MPC Controller:');    
    ControllerLabel.Tag = 'ControllerLabel';
    PlantLabel = Label('Internal Plant:');    
    PlantLabel.Tag = 'PlantLabel';
    % create comboboxes
    ControllerComboBox = DropDown({'mpc1'});    
    ControllerComboBox.Tag = 'ControllerComboBox';
    ControllerComboBox.Description = 'Choose an existing MPC controller to design';
    ControllerComboBox.Value = 'mpc1';
    PlantComboBox = DropDown({'plant1';'plant2';'plant3'});    
    PlantComboBox.Tag = 'PlantComboBox';
    PlantComboBox.Description = 'Choose the internal prediction plant model for the selected controller';
    PlantComboBox.Value = 'plant2';
    % assemble
    add(tab,section);
    add(section, column1);
    add(column1,ControllerLabel);
    add(column1,PlantLabel);
    add(section, column2);
    add(column2,ControllerComboBox);
    add(column2,PlantComboBox);
    %
    ControllerComboBox.ValueChangedFcn = @localPrintComboBox;
    PlantComboBox.ValueChangedFcn = @localPrintComboBox;
end

function createHorizon(tab)
    import matlab.ui.internal.toolstrip.*
    % create section
    section = Section('Horizons');
    section.Tag = 'HorizonSection';
    % create column
    column1 = Column('HorizontalAlignment','right');
    column2 = Column('Width',60);
    % add label
    SampleTimeLabel = Label('Sample time:');
    SampleTimeLabel.Tag = 'SampleTimeLabel';
    PredictionHorizonLabel = Label('Prediction horizon:');
    PredictionHorizonLabel.Tag = 'PredictionHorizonLabel';
    ControlHorizonLabel = Label('Control horizon:');
    ControlHorizonLabel.Tag = 'ControlHorizonLabel';
    % add text field
    SampleTimeTextField = EditField('0.1');
    SampleTimeTextField.Tag = 'SampleTimeTextField';
    SampleTimeTextField.Description = 'Specify controller sample time in the time unit of the plant model'; 
    % add text field
    PredictionHorizonTextField = EditField('10');
    PredictionHorizonTextField.Tag = 'PredictionHorizonTextField';
    PredictionHorizonTextField.Description = 'Specify prediction horizon as number of steps'; 
    % add text field
    ControlHorizonTextField = EditField('3');
    ControlHorizonTextField.Tag = 'ControlHorizonTextField';
    ControlHorizonTextField.Description = 'Specify control horizon as number of steps (no greater than prediction horizon)'; 
    % assemble
    add(tab,section);
    add(section, column1);
    add(column1,SampleTimeLabel);
    add(column1,PredictionHorizonLabel);
    add(column1,ControlHorizonLabel);
    add(section, column2);
    add(column2,SampleTimeTextField);
    add(column2,PredictionHorizonTextField);
    add(column2,ControlHorizonTextField);
    %
    SampleTimeTextField.ValueChangedFcn = @localPrintTextField;
    PredictionHorizonTextField.ValueChangedFcn = @localPrintTextField;
    ControlHorizonTextField.ValueChangedFcn = @localPrintTextField;
end

function createConstraintWeightEstimation(tab)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    % create section
    section = Section('Design');
    section.Tag = 'ConstraintWeightEstimationSection';
    % create column
    column1 = Column();
    column2 = Column();
    column3 = Column();
    % add constraint push button
    ConstraintIcon = Icon([iconpath 'Constraint.png']);
    ConstraintButton = Button('Constraints',ConstraintIcon);            
    ConstraintButton.Tag = 'ConstraintButton';
    ConstraintButton.Description = 'Specify hard and/or soft constraints on plant inputs and outputs'; 
    % add weight push button
    WeightIcon = Icon([iconpath 'Weight.png']);
    WeightButton = Button('Weights',WeightIcon);          
    WeightButton.Tag = 'WeightButton';
    WeightButton.Description = 'Specify weights on plant inputs and outputs'; 
    % add model drop down button
    ModelIcon = Icon([iconpath 'EstimationModel.png']);
    ModelButton = DropDownButton(sprintf('%s\n%s','Estimation','Models'),ModelIcon);      
    ModelButton.Tag = 'ModelButton';
    ModelButton.Description = 'Specify unmeasured disturbance and noise models at plant inputs and outputs'; 
    % create popup
    popup = PopupList();
    item1 = ListItem('Output Disturbance Model',Icon([iconpath 'OutputDisturbance.png']));
    item1.Tag = 'item1';
    item1.Description = 'Specify an LTI model used to describe the characteristics of output disturbances';
    item2 = ListItem('Input Disturbance Model',Icon([iconpath 'InputDisturbance.png']));
    item2.Tag = 'item2';
    item2.Description = 'Specify an LTI model used to describe the characteristics of input disturbances';
    item3 = ListItem('Measurement Noise Model',Icon([iconpath 'MeasurementNoise.png']));
    item3.Tag = 'item3';
    item3.Description = 'Specify an LTI model used to describe the characteristics of measurement noises';
    popup.add(item1);
    popup.add(item2);
    popup.add(item3);
    ModelButton.Popup = popup;
    % assemble
    add(tab,section);
    add(section, column1);
    add(column1,ConstraintButton);
    add(section, column2);
    add(column2,WeightButton);
    add(section, column3);
    add(column3,ModelButton);
end

function createTuning(tab, fig1, fig2)
    import matlab.ui.internal.toolstrip.*
    % create section
    section = Section('Tuning');
    section.Tag = 'TuningSection';
    % create column
    column = Column('Width',280);
    % slider
    WeightSlider = Slider([0 100],50);
    WeightSlider.Tag = 'WeightSlider';
    WeightSlider.Ticks = 5;
    WeightSlider.Description = 'Adjust relative weights between the MV/OV setpoints and the MV rate of change'; 
    WeightSlider.Labels = {'Robust' 0;'Control Performance' 50;'Aggressive' 100};
    % slider
    EstimationSlider = Slider([0 100],50);
    EstimationSlider.Tag = 'EstimationSlider';
    EstimationSlider.Ticks = 5;
    EstimationSlider.Description = 'Adjust relative gains between the disturbance models and the noise model'; 
    EstimationSlider.Labels = {'Slower' 0;'State Estimation' 50;'Faster' 100};
    % assemble
    add(tab,section);
    add(section, column);
    add(column,WeightSlider);
    add(column,EstimationSlider);
    %
    WeightSlider.ValueChangedFcn = @(x,y) localPrintSlider(x,y, fig1, fig2);
    EstimationSlider.ValueChangedFcn = @(x,y) localPrintSlider(x,y, fig1, fig2);
    addlistener(WeightSlider, 'ValueChanging', @localPrintSliderAdjusting);
    addlistener(EstimationSlider, 'ValueChanging', @localPrintSliderAdjusting);
end

function createAnalysis(tab)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    % create section
    section = Section('Analysis');
    section.Tag = 'AnalysisSection';
    % create column
    column1 = Column();
    column2 = Column();
    % add review push button
    ReviewIcon = Icon([iconpath 'Review.png']);
    ReviewButton = ToggleButton(sprintf('%s\n%s','Review','Design'),ReviewIcon);            
    ReviewButton.Tag = 'ReviewButton';
    ReviewButton.Description = 'Review controller design for run time stability and numerical issues'; 
    % add export split button
    ExportIcon = Icon([iconpath 'ExportController.png']);
    ExportButton = SplitButton(sprintf('%s\n%s','Export','Controller'),ExportIcon);            
    ExportButton.Tag = 'ExportButton';
    ExportButton.Description = 'Export MPC controller to base workspace'; 
    % create popup
    popup = PopupList();
    item1 = ListItem('Export Controller',Icon([iconpath 'ExportController.png']));
    item1.Tag = 'item1';
    item1.Description = 'Export MPC controller in the current design to MATLAB workspace';
    item2 = ListItem('Copy Controller',Icon([iconpath 'CopyController.png']));
    item2.Tag = 'item2';
    item2.Description = 'Copy the current design as a new controller in the app';
    item3 = ListItem('Generate Script',Icon([iconpath 'GenerateScript.png']));
    item3.Tag = 'item3';
    item3.Description = 'Generate MATLAB script to reproduce current design at command line';
    popup.add(item1);
    popup.add(item2);
    popup.add(item3);
    ExportButton.Popup = popup;
    % assemble
    add(tab,section);
    add(section, column1);
    add(column1,ReviewButton);
    add(section, column2);
    add(column2,ExportButton);
    %
    ReviewButton.ValueChangedFcn = @localPrintToggleButton;
end

%%
function popup = localBuildDynamicPopupForPlot(src, data, fig1, fig2)
    import matlab.ui.internal.toolstrip.*
    iconpath = [fullfile(matlabroot,'toolbox','matlab','toolstrip','web','mpcdesigner_icons') filesep];
    popup = PopupList();
    header1 = PopupListHeader('Plot Scenario');
    str = ['scenario' num2str(floor(rand*10))];
    item1 = ListItem(str, Icon([iconpath 'GenerateScript.png']));
    item1.Tag = 'item1';
    item1.ShowDescription = false;
    header2 = PopupListHeader('New Scenario');
    str = ['scenario' num2str(floor(rand*10))];
    item2 = ListItem(str, Icon([iconpath 'GenerateScript.png']));
    item2.Tag = 'item2';
    item2.ShowDescription = false;
    popup.add(header1);
    popup.add(item1);
    popup.add(header2);
    popup.add(item2);
    item1.ItemPushedFcn = @(x,y) localUpdatePlot(src, data, fig1, fig2);
    item2.ItemPushedFcn = @(x,y) localUpdatePlot(src, data, fig1, fig2);
end

function popup = localBuildDynamicPopupForCompare(src, data)
    import matlab.ui.internal.toolstrip.*
    popup = PopupList();
    str = ['mpcobj' num2str(floor(rand*10))];
    item1 = ListItemWithCheckBox(str);
    item1.Tag = 'item1';
    item1.ShowDescription = false;
    item1.Value = true;
    str = ['mpcobj' num2str(floor(rand*10))];
    item2 = ListItemWithCheckBox(str);
    item2.Tag = 'item2';
    item2.ShowDescription = false;
    item2.Value = false;
    popup.add(item1);
    popup.add(item2);
    item1.ValueChangedFcn = @localPrintCheckBox;
    item2.ValueChangedFcn = @localPrintCheckBox;
end

function localPrintToggleButton(src, data)
    fprintf('Toggle button changed! %d --> %d\n',data.EventData.OldValue,data.EventData.NewValue);
end

function localPrintCheckBox(src, data)
    fprintf('CheckBoxItem changed! %d --> %d\n',data.EventData.OldValue,data.EventData.NewValue);
end

function localPrintComboBox(src, data)
    fprintf('DropDown changed! %s --> %s\n',data.EventData.OldValue,data.EventData.NewValue);
end

function localPrintTextField(src, data)
    fprintf('EditField changed! %s --> %s\n',data.EventData.OldValue,data.EventData.NewValue);
end

function localPrintSlider(src, data, fig1, fig2)
    localUpdatePlot(src, data, fig1, fig2)
end

function localPrintSliderAdjusting(src, data)
    fprintf('Slider changed to %f!\n',data.EventData.NewValue);
end

function localUpdatePlot(src, data, fig1, fig2)
    plot(gca(fig1), cumsum(rand(100,1)-0.5));
    plot(gca(fig2), cumsum(rand(100,1)-0.5));
end

function localOpenDialog(src, data, app, anchor)
    showTearOffDialog(app.ToolGroup, app.Dialog, anchor, true);
end
