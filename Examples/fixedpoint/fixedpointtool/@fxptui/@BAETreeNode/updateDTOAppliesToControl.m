function updateDTOAppliesToControl(this,hdlg)
%UPDATEDTOAPPLIESTOCONTROL Updates the visibility of the DataTypeAppliesTo
%widget.

%   Copyright 2011 The MathWorks, Inc.

dto_value = hdlg.getWidgetValue('cbo_dt_save_mode');
switch dto_value
    case 0
        dto_str = 'UseLocalSettings';
    case 1
        dto_str = 'ScaledDouble';
    case 2
        dto_str = 'Double';
    case 3
        dto_str = 'Single';
    case 4
        dto_str = 'Off';
    otherwise
        dto_str = 'UseLocalSettings';
end
vis = ~ismember(dto_str,{'UseLocalSettings','Off'});
setVisible(hdlg,'cbo_dt_appliesto_save_mode',vis);

% [EOF]

% [EOF]
