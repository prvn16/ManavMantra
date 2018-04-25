function [T,F,val,isautoscaled] = ...
    eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,emlInputFimath,issigned,varargin)
% SFI(VAL,WL,FL) will return a signed FI object with value VAL,
% word-length WL, fraction-length Fl and an empty fimath

%   Copyright 2008-2013 The MathWorks, Inc.

lvar = length(varargin);

% Check to make sure that varargin is numeric and let embedded.fi do the error checking
for idx = 1:lvar
    if ~isnumeric(varargin{idx})
        error(message('fixed:fi:InvalidInputNotNumeric'));
    end
end

varargin = [varargin(1),issigned,varargin(2:end)];

% Pass in a dummySize input to eml_fi_constructor helper. In this context this input is un-necessary (since it is used to check for data specified by PV pairs, but that cannto happen with sfi or ufi)
dummySize = [1 1];

[T,F,val,isautoscaled] = ...
    eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,...
    emlInputFimath,dummySize,varargin{:});
