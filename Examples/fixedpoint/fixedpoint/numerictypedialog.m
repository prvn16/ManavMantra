function dlgOrTabStruct = numerictypedialog(h, name, isTab)
%NUMERICTYPEDIALOG  Dynamic dialog for numerictype object.
%
%    Example:
%      T = numerictype
%      open T

% Copyright 2004-2012 The MathWorks, Inc.

if nargin == 2 || isempty(isTab)
  isTab = false;
end

rowspan = [0 0];
%-----------------------------------------------------------------------
% First Row contains:
% - dataTypeMode label widget
% - dataTypeMode combobox widget
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
dataTypeModeLbl.Name = getString(message('fixed:numerictype:dialogDataTypeModePrompt'));
dataTypeModeLbl.Type = 'text';
dataTypeModeLbl.RowSpan = rowspan;
dataTypeModeLbl.ColSpan = [1 1];

dataTypeMode.Name = '';
dataTypeMode.RowSpan = rowspan;
dataTypeMode.ColSpan = [2 2];
dataTypeMode.Tag =  'DataTypeMode';
dataTypeMode.Type = 'combobox';
dataTypeMode.Entries = set(h, 'DataTypeMode')';
dataTypeMode.ObjectProperty = 'DataTypeMode';
dataTypeMode.Mode = 1;
dataTypeMode.DialogRefresh = 1;

%-----------------------------------------------------------------------
% Next Row contains:
% - signedness label widget
% - signedness combobox widget
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
signednessLbl.Name = getString(message('fixed:numerictype:dialogSignednessPrompt'));
signednessLbl.Type = 'text';
signednessLbl.RowSpan = rowspan;
signednessLbl.ColSpan = [1 1];

signedness.Name = '';
signedness.RowSpan = rowspan;
signedness.ColSpan = [2 2];
signedness.Tag =  'Signedness';
signedness.Type = 'combobox';
signedness.Entries = set(h, 'Signedness')';
signedness.ObjectProperty = 'Signedness';
signedness.Mode = 1;
signedness.DialogRefresh = 1;

if isscaledtype(h)
    signednessLbl.Visible = 1;
    signedness.Visible = 1;
else
    signednessLbl.Visible = 0;
    signedness.Visible = 0;
end;

%-----------------------------------------------------------------------
% Next Row contains:
% - Wordlength label widget
% - Wordlength edit field widget
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
wordLengthLbl.Name = getString(message('fixed:numerictype:dialogWordLengthPrompt'));
wordLengthLbl.Type = 'text';
wordLengthLbl.RowSpan = rowspan;
wordLengthLbl.ColSpan = [1 1];

wordLength.Name = '';
wordLength.RowSpan = rowspan;
wordLength.ColSpan = [2 2];
wordLength.Tag = 'WordLength';
wordLength.Type = 'edit';
wordLength.ObjectProperty = 'PrivDDGWordLengthString'; 
wordLength.Mode = 1;
if isscaledtype(h)
    wordLengthLbl.Visible = 1;
    wordLength.Visible    = 1;
else
    wordLengthLbl.Visible = 0;
    wordLength.Visible    = 0;
end;

%-----------------------------------------------------------------------
% Next Row contains:
% - Fraction length label widget
% - Fraction length edit field widget
% (only visible for Fixed-point: Binary point scaling mode)
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
fracLenLbl.Name = getString(message('fixed:numerictype:dialogFractionLengthPrompt'));
fracLenLbl.Type = 'text';
fracLenLbl.RowSpan = rowspan;
fracLenLbl.ColSpan = [1 1];

fracLen.Name = '';
fracLen.RowSpan = rowspan;
fracLen.ColSpan = [2 2];
fracLen.Tag = 'FractionLength';
fracLen.Type = 'edit';
fracLen.ObjectProperty = 'PrivDDGFractionLengthString';
fracLen.Mode = 1;
fracLen.DialogRefresh = 1;
if isbinarypointscalingset(h)
    fracLenLbl.Visible = 1;
    fracLen.Visible    = 1;
else
    fracLenLbl.Visible = 0;
    fracLen.Visible    = 0;
end

%-----------------------------------------------------------------------
% Next Row contains:
% - Slope label widget
% - Slope edit field widget
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
slopeLbl.Name = getString(message('fixed:numerictype:dialogSlopePrompt'));
slopeLbl.Type = 'text';
slopeLbl.RowSpan = rowspan;
slopeLbl.ColSpan = [1 1];

slope.Name = '';
slope.RowSpan = rowspan;
slope.ColSpan = [2 2];
slope.Type = 'edit';
slope.Tag = 'Slope';
slope.ObjectProperty = 'PrivDDGSlopeString'; 
slope.Mode = 1;
slope.DialogRefresh = 1;
if isslopebiasscalingset(h)
    slopeLbl.Visible = 1;
    slope.Visible    = 1;
else
    slopeLbl.Visible = 0;
    slope.Visible    = 0;
end;

%-----------------------------------------------------------------------
% Next Row contains:
% - Bias label widget
% - Bias edit field widget
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
biasLbl.Name = getString(message('fixed:numerictype:dialogBiasPrompt'));
biasLbl.Type = 'text';
biasLbl.RowSpan = rowspan;
biasLbl.ColSpan = [1 1];

bias.Name = '';
bias.RowSpan = rowspan;
bias.ColSpan = [2 2];
bias.Type = 'edit';
bias.Tag = 'Bias';
bias.ObjectProperty = 'PrivDDGBiasString';
bias.Mode = 1;
if isslopebiasscalingset(h)
    biasLbl.Visible = 1;
    bias.Visible    = 1;
else
    biasLbl.Visible = 0;
    bias.Visible    = 0;
end;

%-----------------------------------------------------------------------
% Next Row contains:
% - ObeyDTO label widget
% - ObeyDTO checkbox widget
%----------------------------------------------------------------------- 
rowspan = rowspan + 1;
dataTypeOverrideLbl.Name = getString(message('fixed:numerictype:dialogDTOPrompt'));
dataTypeOverrideLbl.Type = 'text';
dataTypeOverrideLbl.RowSpan = rowspan;
dataTypeOverrideLbl.ColSpan = [1 1];

comboDataTypeOverride.Name = '';
comboDataTypeOverride.RowSpan = rowspan;
comboDataTypeOverride.ColSpan = [2 2];
comboDataTypeOverride.Type = 'combobox';
comboDataTypeOverride.Entries = {'Inherit', 'Off'};
comboDataTypeOverride.Tag = 'DataTypeOverride';
comboDataTypeOverride.ObjectProperty = 'DataTypeOverride';


%-----------------------------------------------------------------------
% Assemble main dialog or tab struct
%-----------------------------------------------------------------------  
dialogTitleStr = getString(message('fixed:numerictype:dialogTitle', name));
if ~isTab % is a dialog
  dlgOrTabStruct.DialogTitle = dialogTitleStr;
  dlgOrTabStruct.HelpMethod  = 'helpview';
  dlgOrTabStruct.HelpArgs    = ...
      {[docroot, '/toolbox/fixedpoint/fixedpoint.map'], 'numerictype_dialog'};
else % is a tab
  dlgOrTabStruct.Name = dialogTitleStr;
end

dlgOrTabStruct.Items = {dataTypeModeLbl, dataTypeMode, ... 
                   signednessLbl, signedness, ...
                   wordLengthLbl, wordLength, ...
                   fracLenLbl, fracLen, ...
                   slopeLbl, slope, ...
                   biasLbl, bias, ...
                   dataTypeOverrideLbl, comboDataTypeOverride};
dlgOrTabStruct.LayoutGrid = [rowspan(1)+1 2];  % +1 to include the title
dlgOrTabStruct.RowStretch = [zeros(1,rowspan(1)) 1];
dlgOrTabStruct.ColStretch = [0 1];
if ~isempty(name) && ischar(name)
    dlgOrTabStruct.DialogTag = ['embedded.numerictype:',name];
end

