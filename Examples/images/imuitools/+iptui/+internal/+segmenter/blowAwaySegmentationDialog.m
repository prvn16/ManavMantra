function TF = blowAwaySegmentationDialog()
%blowAwaySegmentationDialog - Launch warning dialog for threshold being
%a blow-out operation.

% Copyright 2015-2016 The MathWorks, Inc.

TF = false;

warnstring = getString(message('images:imageSegmenter:blowAwaySegmentationDlgString'));
dlgname    = getString(message('images:imageSegmenter:blowAwaySegmentationDlgName'));
yesbtn     = getString(message('images:commonUIString:yes'));
cancelbtn  = getString(message('images:commonUIString:cancel'));

dlg = questdlg(warnstring,dlgname,yesbtn,cancelbtn,cancelbtn);

switch dlg
    case yesbtn
        TF = true;
    case cancelbtn
        TF = false;
end
end
