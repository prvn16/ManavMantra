function updateDTOAppliesToControl(hdlg)
% UPDATEDTOAPPLIESTOCONTROL Updates the visibility of the data types to
% override widget.

% Copyright 2013 MathWorks, Inc.

    dto_value = hdlg.getWidgetValue('cbo_dt');
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
    setVisible(hdlg,'cbo_dt_appliesto',vis);
end
