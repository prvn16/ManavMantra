function schema = FPTContextMenus( fncname, cbinfo )
% FPTContextMenus Define the custom context menu function.

%   Copyright 2015-2016 The MathWorks, Inc.

    fcn = str2func( fncname );
    schema = fcn( cbinfo );
return;

%% Define the schema function for "Traceability"
function schema = FixedPointInterfaceBlockContextMenu( cbinfo ) 
if slfeature('FPTTraceability')
    if slfeature('FPTWeb')
        me = fxptui.FixedPointTool.getExistingInstance;
    else 
        me = fxptui.getexplorer;
    end
    blockObject = getBlockObject(cbinfo);
     
    if isempty(me) || ~me.isFPTLaunchedOnSameModel(cbinfo.model) || ... %is FPT already open on model
            isa(blockObject,'Simulink.SubSystem') || ... 
            fxptds.isStateflowChartObject(blockObject) || ...
            fxptds.isSFMaskedSubsystem(blockObject) || ...
            isa(blockObject, 'Simulink.ModelReference') || ...    
            fxptui.isDataSetEmptyForModel(blockObject) % check whether ds is empty or not
            
        % Check the object on which context menu is being launched.
        % Traceability will work on SL blocks for now. 
        % The above code checks if the selected block is not a Subsystem,
        % SF entity, Model reference block, or FPT dataset is empty. 
        % If any of the above condition is true show the message as
        % "Fixed-Point Tool"
        schema = getFixedPointToolSchema;
    else
        % get the context menu shcema for "Fixed-Point Tool Result"
        schema = getFPTBlockCMSchema(blockObject);
    end
else
    schema = getFixedPointToolSchema;
end
return

function blockObject = getBlockObject ( cbinfo )
% return the blockObject from cbinfo
    blockObject = [];
    aSelectedItem = SLStudio.Utils.getSingleSelectedBlock(cbinfo);    
    if ~isempty(aSelectedItem)
        blockObject = get_param(aSelectedItem.handle,'Object');
    end


function schema = getFPTBlockCMSchema( blockObject )
% Context menu schema for 'Fixed-Point Tool Result'
    schema = sl_action_schema;
    schema.tag      = 'Simulink:FixedPointInterfaceBlockContextMenu';
    schema.label    = DAStudio.message('Simulink:studio:ResultInFixedPointTool');
    schema.callback =  @(x) resultInFixedPointToolCB(blockObject);
    schema.autoDisableWhen = 'Busy';


    function resultInFixedPointToolCB(blkObject)
% Callback for traceability of result in FPT
fxptui.cb_hiliteResultInFPT(blkObject);

function schema = getFixedPointToolSchema
    %% create a schema for Fixed-Point Tool Action.
    % This action is used for "Fixed-Point Tool..."
    schema = sl_action_schema;
    schema.tag      = 'Simulink:FixedPointInterface';
    schema.label    = DAStudio.message('Simulink:studio:FixedPointInterface');
    schema.callback = @FixedPointToolCB;
    
    schema.autoDisableWhen = 'Busy';


function FixedPointToolCB( cbinfo )
    sysHandle = SLStudio.Utils.getSLHandleForSelectedHierarchicalBlock(cbinfo);
    fixptopt(sysHandle);

