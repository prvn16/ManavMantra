function dlgOrTabStruct = fimathdialog(h, name,isTab)
%FIMATHDIALOG  Dynamic dialog for fimath object.
%
%    Example:
%      F = fimath
%      open F

% Copyright 2005-2014 The MathWorks, Inc.

if nargin == 2 || isempty(isTab)
  isTab = false;
end

%-----------------------------------------------------------------------
% First Row contains:
% - RoundingMethod label widget
% - RoundingMethod combobox widget
%----------------------------------------------------------------------- 
RoundingMethodLbl.Name = getString(message('fixed:fimath:dialogRoundingMethodPrompt'));
RoundingMethodLbl.Type = 'text';
RoundingMethodLbl.RowSpan = [1 1];
RoundingMethodLbl.ColSpan = [1 1];
RoundingMethodLbl.Tag = 'RoundingMethodLbl';

RoundingMethod.Name = '';
RoundingMethod.RowSpan = [1 1];
RoundingMethod.ColSpan = [2 2];
RoundingMethod.Tag = 'RoundingMethod';
RoundingMethod.Type = 'combobox';
RoundingMethod.Entries = set(h, 'RoundingMethod');
RoundingMethod.ObjectProperty = 'RoundingMethod';
RoundingMethod.Mode = 1;
RoundingMethod.DialogRefresh = 1;

%-----------------------------------------------------------------------
% Second Row contains:
% - OverflowAction label widget
% - OverflowAction combobox widget
%----------------------------------------------------------------------- 
OverflowActionLbl.Name = getString(message('fixed:fimath:dialogOverflowActionPrompt'));
OverflowActionLbl.Type = 'text';
OverflowActionLbl.RowSpan = [2 2];
OverflowActionLbl.ColSpan = [1 1];
OverflowActionLbl.Tag = 'OverflowActionLbl';

OverflowAction.Name = '';
OverflowAction.RowSpan = [2 2];
OverflowAction.ColSpan = [2 2];
OverflowAction.Tag = 'OverflowAction';
OverflowAction.Type = 'combobox';
OverflowAction.Entries = set(h,'OverflowAction'); 
OverflowAction.ObjectProperty = 'OverflowAction';
OverflowAction.Mode = 1;
OverflowAction.DialogRefresh = 1;


%-----------------------------------------------------------------------
% Third Row contains:
% - ProductMode label widget
% - ProductMode combobox widget
%----------------------------------------------------------------------- 
ProductModeLbl.Name = getString(message('fixed:fimath:dialogProductModePrompt'));
ProductModeLbl.Type = 'text';
ProductModeLbl.RowSpan = [3 3];
ProductModeLbl.ColSpan = [1 1];
ProductModeLbl.Tag = 'ProductModeLbl';

ProductMode.Name = '';
ProductMode.RowSpan = [3 3];
ProductMode.ColSpan = [2 2];
ProductMode.Tag = 'ProductMode';
ProductMode.Type = 'combobox';
ProductMode.Entries = set(h,'ProductMode')';
ProductMode.ObjectProperty = 'ProductMode';
ProductMode.Mode = 1;
ProductMode.DialogRefresh = 1;
prodmodeVal = h.ProductMode;

%-----------------------------------------------------------------------
% Fourth Row contains:
% - ProductWordLength label widget
% - ProductWordLength edit box widget
%----------------------------------------------------------------------- 
ProductWordLengthLbl.Name = getString(message('fixed:fimath:dialogProductWordLengthPrompt'));
ProductWordLengthLbl.Type = 'text';
ProductWordLengthLbl.RowSpan = [4 4];
ProductWordLengthLbl.ColSpan = [1 1];
ProductWordLengthLbl.Tag = 'ProductWordLengthLbl';

ProductWordLength.Name = '';
ProductWordLength.RowSpan = [4 4];
ProductWordLength.ColSpan = [2 2];
ProductWordLength.Tag = 'ProductWordLength';
ProductWordLength.Type = 'edit';
ProductWordLength.ObjectProperty = 'PrivDDGProductWordLengthString';
ProductWordLength.Mode = 1;
%ProductWordLength.DialogRefresh = 1;
if strcmpi(prodmodeVal,'FullPrecision')
    % Not applicable
    ProductWordLengthLbl.Visible = 0;
    ProductWordLength.Visible = 0;
else
    ProductWordLengthLbl.Visible = 1;
    ProductWordLength.Visible = 1;
end

%----------------------------------------------------------------------- 
% Fifth Row contains:
% - ProductFractionLength label widget
% - ProductFractionLength edit box widget
%-----------------------------------------------------------------------
ProductFractionLengthLbl.Name = getString(message('fixed:fimath:dialogProductFractionLengthPrompt'));
ProductFractionLengthLbl.Type = 'text';
ProductFractionLengthLbl.RowSpan = [5 5];
ProductFractionLengthLbl.ColSpan = [1 1];
ProductFractionLengthLbl.Tag = 'ProductFractionLengthLbl';

ProductFractionLength.Name = '';
ProductFractionLength.RowSpan = [5 5];
ProductFractionLength.ColSpan = [2 2];
ProductFractionLength.Tag = 'ProductFractionLength';
ProductFractionLength.Type = 'edit';
ProductFractionLength.ObjectProperty = 'PrivDDGProductFractionLengthString';
ProductFractionLength.Mode = 1;
ProductFractionLength.DialogRefresh = 1;
prodBiasVal = h.ProductBias;
prodSAFVal = h.ProductSlopeAdjustmentFactor;
if (strcmpi(prodmodeVal,'SpecifyPrecision') && prodBiasVal==0 && prodSAFVal==1)
    ProductFractionLengthLbl.Visible = 1;
    ProductFractionLength.Visible = 1;
else
    % Not applicable
    ProductFractionLengthLbl.Visible = 0;
    ProductFractionLength.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Sixth Row contains:
% - ProductSlope label widget
% - ProductSlope edit box widget
%-----------------------------------------------------------------------
ProductSlopeLbl.Name = getString(message('fixed:fimath:dialogProductSlopePrompt'));
ProductSlopeLbl.Type = 'text';
ProductSlopeLbl.RowSpan = [6 6];
ProductSlopeLbl.ColSpan = [1 1];
ProductSlopeLbl.Tag = 'ProductSlopeLbl';

ProductSlope.Name = '';
ProductSlope.RowSpan = [6 6];
ProductSlope.ColSpan = [2 2];
ProductSlope.Tag = 'ProductSlope';
ProductSlope.Type = 'edit';
ProductSlope.ObjectProperty = 'PrivDDGProductSlopeString';
ProductSlope.Mode = 1;
ProductSlope.DialogRefresh = 1;
prodBiasVal = h.ProductBias;
prodSAFVal = h.ProductSlopeAdjustmentFactor;
if (strcmpi(prodmodeVal,'SpecifyPrecision') && (prodBiasVal~=0 || prodSAFVal~=1))
    ProductSlopeLbl.Visible = 1;
    ProductSlope.Visible = 1;
else
    % Not applicable
    ProductSlopeLbl.Visible = 0;
    ProductSlope.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Seventh Row contains:
% - ProductSlope label widget
% - ProductSlope edit box widget
%-----------------------------------------------------------------------
ProductBiasLbl.Name = getString(message('fixed:fimath:dialogProductBiasPrompt'));
ProductBiasLbl.Type = 'text';
ProductBiasLbl.RowSpan = [7 7];
ProductBiasLbl.ColSpan = [1 1];
ProductBiasLbl.Tag = 'ProductBiasLbl';

ProductBias.Name = '';
ProductBias.RowSpan = [7 7];
ProductBias.ColSpan = [2 2];
ProductBias.Tag = 'ProductBias';
ProductBias.Type = 'edit';
ProductBias.ObjectProperty = 'PrivDDGProductBiasString';
ProductBias.Mode = 1;
%ProductBias.DialogRefresh = 1;
prodBiasVal = h.ProductBias;
prodSAFVal = h.ProductSlopeAdjustmentFactor;
if (strcmpi(prodmodeVal,'SpecifyPrecision') && (prodBiasVal~=0 || prodSAFVal~=1))
    ProductBiasLbl.Visible = 1;
    ProductBias.Visible = 1;
else
    % Not applicable
    ProductBiasLbl.Visible = 0;
    ProductBias.Visible = 0;
end 

%-----------------------------------------------------------------------
% Eighth Row contains:
% - SumMode label widget
% - SumMode combobox widget
%----------------------------------------------------------------------- 
SumModeLbl.Name = getString(message('fixed:fimath:dialogSumModePrompt'));
SumModeLbl.Type = 'text';
SumModeLbl.RowSpan = [8 8];
SumModeLbl.ColSpan = [1 1];
SumModeLbl.Tag = 'SumModeLbl';

SumMode.Name = '';
SumMode.RowSpan = [8 8];
SumMode.ColSpan = [2 2];
SumMode.Tag = 'SumMode';
SumMode.Type = 'combobox';
SumMode.Entries = set(h,'SumMode')';
SumMode.ObjectProperty = 'SumMode';
SumMode.Mode = 1;
SumMode.DialogRefresh = 1;
summodeVal = h.SumMode;

%-----------------------------------------------------------------------
% Ninth Row contains:
% - SumWordLength label widget
% - SumWordLength edit box widget
%----------------------------------------------------------------------- 
SumWordLengthLbl.Name = getString(message('fixed:fimath:dialogSumWordLengthPrompt'));
SumWordLengthLbl.Type = 'text';
SumWordLengthLbl.RowSpan = [9 9];
SumWordLengthLbl.ColSpan = [1 1];
SumWordLengthLbl.Tag = 'SumWordLengthLbl';

SumWordLength.Name = '';
SumWordLength.RowSpan = [9 9];
SumWordLength.ColSpan = [2 2];
SumWordLength.Tag = 'SumWordLength';
SumWordLength.Type = 'edit';
SumWordLength.ObjectProperty = 'PrivDDGSumWordLengthString';
SumWordLength.Mode = 1;
%SumWordLength.DialogRefresh = 1;
if strcmpi(summodeVal,'FullPrecision')
    % Not applicable
    SumWordLengthLbl.Visible = 0;
    SumWordLength.Visible = 0;
else
    SumWordLengthLbl.Visible = 1;
    SumWordLength.Visible = 1;
end

%-----------------------------------------------------------------------
% Tenth Row contains:
% - SumFractionLength label widget
% - SumFractionLength edit box widget
%----------------------------------------------------------------------- 
SumFractionLengthLbl.Name = getString(message('fixed:fimath:dialogSumFractionLengthPrompt'));
SumFractionLengthLbl.Type = 'text';
SumFractionLengthLbl.RowSpan = [10 10];
SumFractionLengthLbl.ColSpan = [1 1];
SumFractionLengthLbl.Tag = 'SumFractionLengthLbl';

SumFractionLength.Name = '';
SumFractionLength.RowSpan = [10 10];
SumFractionLength.ColSpan = [2 2];
SumFractionLength.Tag = 'SumFractionLength';
SumFractionLength.Type = 'edit';
SumFractionLength.ObjectProperty = 'PrivDDGSumFractionLengthString';
SumFractionLength.Mode = 1;
SumFractionLength.DialogRefresh = 1;
sumBiasVal = h.SumBias;
sumSAFVal = h.SumSlopeAdjustmentFactor;
if (strcmpi(summodeVal,'SpecifyPrecision') && sumBiasVal==0 && sumSAFVal==1)
    SumFractionLengthLbl.Visible = 1;
    SumFractionLength.Visible = 1;
else
    % Not applicable
    SumFractionLengthLbl.Visible = 0;
    SumFractionLength.Visible = 0;
end


%----------------------------------------------------------------------- 
% Eleventh Row contains:
% - SumSlope label widget
% - SumSlope edit box widget
%-----------------------------------------------------------------------
SumSlopeLbl.Name = getString(message('fixed:fimath:dialogSumSlopePrompt'));
SumSlopeLbl.Type = 'text';
SumSlopeLbl.RowSpan = [11 11];
SumSlopeLbl.ColSpan = [1 1];
SumSlopeLbl.Tag = 'SumSlopeLbl';

SumSlope.Name = '';
SumSlope.RowSpan = [11 11];
SumSlope.ColSpan = [2 2];
SumSlope.Tag = 'SumSlope';
SumSlope.Type = 'edit';
SumSlope.ObjectProperty = 'PrivDDGSumSlopeString';
SumSlope.Mode = 1;
SumSlope.DialogRefresh = 1;
if (strcmpi(summodeVal,'SpecifyPrecision') && (sumBiasVal~=0 || sumSAFVal~=1))
    SumSlopeLbl.Visible = 1;
    SumSlope.Visible = 1;
else
    % Not applicable
    SumSlopeLbl.Visible = 0;
    SumSlope.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Twelfth Row contains:
% - SumSlope label widget
% - SumSlope edit box widget
%-----------------------------------------------------------------------
SumBiasLbl.Name = getString(message('fixed:fimath:dialogSumBiasPrompt'));
SumBiasLbl.Type = 'text';
SumBiasLbl.RowSpan = [12 12];
SumBiasLbl.ColSpan = [1 1];
SumBiasLbl.Tag = 'SumBiasLbl';

SumBias.Name = '';
SumBias.RowSpan = [12 12];
SumBias.ColSpan = [2 2];
SumBias.Tag = 'SumBias';
SumBias.Type = 'edit';
SumBias.ObjectProperty = 'PrivDDGSumBiasString';
SumBias.Mode = 1;
SumBias.DialogRefresh = 1;
if (strcmpi(summodeVal,'SpecifyPrecision') && (sumBiasVal~=0 || sumSAFVal~=1))
    SumBiasLbl.Visible = 1;
    SumBias.Visible = 1;
else
    % Not applicable
    SumBiasLbl.Visible = 0;
    SumBias.Visible = 0;
end 


%-----------------------------------------------------------------------
% Thirteenth Row contains:
% - CastBeforeSum checkbox widget
%----------------------------------------------------------------------- 
CastBeforeSum.Name = getString(message('fixed:fimath:dialogCastBeforeSumPrompt'));
CastBeforeSum.RowSpan = [13 13];
CastBeforeSum.ColSpan = [1 1];
CastBeforeSum.Type = 'checkbox';
CastBeforeSum.Tag = 'CastBeforeSum';
CastBeforeSum.ObjectProperty = 'CastBeforeSum';
CastBeforeSum.Mode = 1;
CastBeforeSum.DialogRefresh = 1;
if strcmpi(summodeVal,'FullPrecision')
    % Not applicable
    CastBeforeSum.Visible = 0;
else
    CastBeforeSum.Visible = 1;
end

%-----------------------------------------------------------------------
% Assemble main dialog or tab struct
%-----------------------------------------------------------------------  
dialogTitleStr = getString(message('fixed:fimath:dialogTitle', name));
if ~isTab % is a dialog
 if isa(h,'embedded.globalfimath')
  dlgOrTabStruct.DialogTitle = 'Global Fimath';
 else
  dlgOrTabStruct.DialogTitle = dialogTitleStr;
 end
 dlgOrTabStruct.HelpMethod = 'helpview';
 dlgOrTabStruct.HelpArgs   = ...
     {[docroot ,'/toolbox/fixedpoint/fixedpoint.map'], 'fimath_dialog'};
else % is a tab
  dlgOrTabStruct.Name = dialogTitleStr;
end

dlgOrTabStruct.Items = {RoundingMethodLbl, RoundingMethod,...
                   OverflowActionLbl, OverflowAction,...
                   ProductModeLbl, ProductMode,...
                   ProductWordLengthLbl,ProductWordLength,...
                   ProductFractionLengthLbl,ProductFractionLength,...
                   ProductSlopeLbl,ProductSlope,...
                   ProductBiasLbl,ProductBias,...
                   SumModeLbl, SumMode,...
                   SumWordLengthLbl,SumWordLength,...
                   SumFractionLengthLbl,SumFractionLength,...
                   SumSlopeLbl,SumSlope,...
                   SumBiasLbl,SumBias,...
                   CastBeforeSum};

dlgOrTabStruct.LayoutGrid = [14 2];
dlgOrTabStruct.RowStretch = [0 0 0 0 0 0 0 0 0 0 0 0 0 1];
dlgOrTabStruct.ColStretch = [0 1];
if ~isempty(name) && ischar(name)
    dlgOrTabStruct.DialogTag = ['embedded.fimath:',name];
end
