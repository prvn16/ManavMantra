function initFactoryShortcutMap(h)
%INITFACTORYSHORTCUTMAP Initializes the factory maps for the model

%   Copyright 2011-2015 The MathWorks, Inc.

bdroot = h.getFPTRoot.getDAObject;
mlfbConversionEnabled = fxptui.isMATLABFunctionBlockConversionEnabled();

% Create the map to store batch actions.
h.FactoryBatchNameSettingsMap = Simulink.sdi.Map(char('a'),?handle);

% Create floating-point Dbl override factory settings

fltptfactorySettingsBlkMap = Simulink.sdi.Map(char('a'),?handle);
fltptfactorySettingsMap = Simulink.sdi.Map(char('a'),?handle);
fltptfactorySettingsValueMap = Simulink.sdi.Map(char('a'),?handle);
fltptfactorySettingsValueMap.insert('DataTypeOverride','Double');
fltptfactorySettingsValueMap.insert('DataTypeOverrideAppliesTo','AllNumericTypes');
fltptfactorySettingsValueMap.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
if mlfbConversionEnabled
    fltptfactorySettingsValueMap.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingOriginal);
end
fltptfactorySettingsMap.insert(Simulink.ID.getSID(bdroot), fltptfactorySettingsValueMap);
fltptfactorySettingsBlkMap.insert('SystemSettingMap',fltptfactorySettingsMap);

fltptfactorySettingsGlobalMap = Simulink.sdi.Map(char('a'),?handle);
fltptfactorySettingsGlobalMap.insert('CaptureDTO',true);
fltptfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
fltptfactorySettingsGlobalMap.insert('ModifyDefaultRun',true);
fltptfactorySettingsGlobalMap.insert('RunName',fxptui.message('lblDblOverrideRunName'));
fltptfactorySettingsBlkMap.insert('GlobalModelSettings',fltptfactorySettingsGlobalMap);

h.FactoryBatchNameSettingsMap.insert(fxptui.message('lblDblOverride'),fltptfactorySettingsBlkMap); 


% Create fixed-point factory settings
fixptfactorySettingsBlkMap1 = Simulink.sdi.Map(char('a'),?handle);
fixptfactorySettingsMap = Simulink.sdi.Map(char('a'),?handle);
fixptfactorySettingsValueMap1 = Simulink.sdi.Map(char('a'),?handle);
fixptfactorySettingsValueMap1.insert('DataTypeOverride','UseLocalSettings');
fixptfactorySettingsValueMap1.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
if mlfbConversionEnabled
    fixptfactorySettingsValueMap1.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingFixedPoint);
end
fixptfactorySettingsMap.insert(Simulink.ID.getSID(bdroot), fixptfactorySettingsValueMap1);
fixptfactorySettingsBlkMap1.insert('SystemSettingMap',fixptfactorySettingsMap);

fixptfactorySettingsGlobalMap1 = Simulink.sdi.Map(char('a'),?handle);
fixptfactorySettingsGlobalMap1.insert('CaptureDTO',true);
fixptfactorySettingsGlobalMap1.insert('CaptureInstrumentation',true);
fixptfactorySettingsGlobalMap1.insert('ModifyDefaultRun',true);
fixptfactorySettingsGlobalMap1.insert('RunName',fxptui.message('lblFxptOverrideRunName'));
fixptfactorySettingsBlkMap1.insert('GlobalModelSettings', fixptfactorySettingsGlobalMap1);

h.FactoryBatchNameSettingsMap.insert(fxptui.message('lblFxptOverride'),fixptfactorySettingsBlkMap1);

% Create floating-point Sgl override factory settings
sglfltptfactorySettingsBlkMap = Simulink.sdi.Map(char('a'),?handle);
sglfltptfactorySettingsMap = Simulink.sdi.Map(char('a'),?handle);
sglfltptfactorySettingsValueMap = Simulink.sdi.Map(char('a'),?handle);
sglfltptfactorySettingsValueMap.insert('DataTypeOverride','Single');
sglfltptfactorySettingsValueMap.insert('DataTypeOverrideAppliesTo','AllNumericTypes');
sglfltptfactorySettingsValueMap.insert('MinMaxOverflowLogging','MinMaxAndOverflow');
if mlfbConversionEnabled
    sglfltptfactorySettingsValueMap.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingOriginal);
end
sglfltptfactorySettingsMap.insert(Simulink.ID.getSID(bdroot), sglfltptfactorySettingsValueMap);
sglfltptfactorySettingsBlkMap.insert('SystemSettingMap',sglfltptfactorySettingsMap);


sglfltptfactorySettingsGlobalMap = Simulink.sdi.Map(char('a'),?handle);
sglfltptfactorySettingsGlobalMap.insert('CaptureDTO',true);
sglfltptfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
sglfltptfactorySettingsGlobalMap.insert('ModifyDefaultRun',true);
sglfltptfactorySettingsGlobalMap.insert('RunName',fxptui.message('lblSglOverrideRunName'));
sglfltptfactorySettingsBlkMap.insert('GlobalModelSettings',sglfltptfactorySettingsGlobalMap);

h.FactoryBatchNameSettingsMap.insert(fxptui.message('lblSglOverride'),sglfltptfactorySettingsBlkMap);

% Create factory settings to turn Off instrumentation
instrumentationfactorySettingsBlkMap = Simulink.sdi.Map(char('a'),?handle);
instrumentationfactorySettingsMap = Simulink.sdi.Map(char('a'),?handle);
instrumentationfactorySettingsValueMap = Simulink.sdi.Map(char('a'),?handle);
instrumentationfactorySettingsValueMap.insert('MinMaxOverflowLogging','UseLocalSettings');
instrumentationfactorySettingsMap.insert(Simulink.ID.getSID(bdroot), instrumentationfactorySettingsValueMap);
instrumentationfactorySettingsBlkMap.insert('SystemSettingMap',instrumentationfactorySettingsMap);
instrumentationfactorySettingsGlobalMap = Simulink.sdi.Map(char('a'),?handle);
instrumentationfactorySettingsGlobalMap.insert('CaptureDTO',false);
instrumentationfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
instrumentationfactorySettingsGlobalMap.insert('ModifyDefaultRun',false);
instrumentationfactorySettingsBlkMap.insert('GlobalModelSettings', instrumentationfactorySettingsGlobalMap);

h.FactoryBatchNameSettingsMap.insert(fxptui.message('lblMMOOff'),instrumentationfactorySettingsBlkMap);

dtoinstrumentationfactorySettingsBlkMap = Simulink.sdi.Map(char('a'),?handle);
dtoinstrumentationfactorySettingsMap = Simulink.sdi.Map(char('a'),?handle);
dtoinstrumentationfactorySettingsValueMap = Simulink.sdi.Map(char('a'),?handle);
dtoinstrumentationfactorySettingsValueMap.insert('DataTypeOverride','UseLocalSettings');
dtoinstrumentationfactorySettingsValueMap.insert('MinMaxOverflowLogging','UseLocalSettings');
if mlfbConversionEnabled
    dtoinstrumentationfactorySettingsValueMap.insert('MLFBVariant',coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingFixedPoint);
end
dtoinstrumentationfactorySettingsMap.insert(Simulink.ID.getSID(bdroot), dtoinstrumentationfactorySettingsValueMap);
dtoinstrumentationfactorySettingsBlkMap.insert('SystemSettingMap',dtoinstrumentationfactorySettingsMap);

dtoinstrumentationfactorySettingsGlobalMap = Simulink.sdi.Map(char('a'),?handle);
dtoinstrumentationfactorySettingsGlobalMap.insert('CaptureDTO',true);
dtoinstrumentationfactorySettingsGlobalMap.insert('CaptureInstrumentation',true);
dtoinstrumentationfactorySettingsGlobalMap.insert('ModifyDefaultRun',false);
dtoinstrumentationfactorySettingsBlkMap.insert('GlobalModelSettings', dtoinstrumentationfactorySettingsGlobalMap);

h.FactoryBatchNameSettingsMap.insert(fxptui.message('lblDTOMMOOff'),dtoinstrumentationfactorySettingsBlkMap);


% [EOF]
