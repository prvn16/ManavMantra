function dlg = invalidSegmentationDialog()
%invalidSegmentationDialog - Launch warning dialog for invalid
%segmentation.

% Copyright 2014 The MathWorks, Inc.

warnstring = getString(message('images:imageSegmenter:badSegmentationDlgString'));
dlgname    = getString(message('images:imageSegmenter:badSegmentationDlgName'));
createmode = 'modal';

dlg = warndlg(warnstring,dlgname,createmode);
end
