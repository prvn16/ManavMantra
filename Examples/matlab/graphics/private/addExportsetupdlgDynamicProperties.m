% Copyright 2009-2011 The MathWorks, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions - MCOS transition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the dynamic propety.

function addExportsetupdlgDynamicProperties(FigHandle)
p = findprop(FigHandle, 'ExportsetupWindow');
if ~useOriginalHGPrinting(FigHandle)
    assert(isa(FigHandle, 'dynamicprops'));
    if isempty(p)
        p = addprop(FigHandle, 'ExportsetupWindow');
        p.Transient=true;
    end
else
    if isempty(p)
        p = schema.prop(FigHandle, 'ExportsetupWindow', 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.Visible = 'off';
    end
end
