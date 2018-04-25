function [chan_in, chan_out] = luttagchans(luttag)
%LUTTAGCHANS Return number of input and output channels 
%   [CHAN_IN, CHAN_OUT] = LUTTAGCHANS(LUTTAG) determines
%   the connectivity of a given tag, LUTTAG, of any of
%   the v. 2 or v. 4 types (lut8Type, lut16Type, lutAtoBType,
%   lutBtoAType).  CHAN_IN and CHAN_OUT are the number of
%   input and output channels, respectively.
%
%   Called from ICCWRITE/encode_lut_type and from
%   APPLYCLUT.
%
%   Copyright 2005 The MathWorks, Inc.
%      Poe
%   Original authors: Scott Gregory, Toshia McCabe, Robert Poe 07/03/05

if luttag.MFT < 3              % lut8Type or lut16Type
    chan_in = size(luttag.InputTables, 2);    % required field
    chan_out = size(luttag.OutputTables, 2);  % required field
elseif luttag.MFT == 3         % lutAtoBType
    chan_out = size(luttag.PostShaper, 2);    % required field
    % should == 3 (PCS)
    if isempty(luttag.CLUT)
        chan_in = chan_out;
    elseif chan_out > 1
        chan_in = ndims(luttag.CLUT) - 1;
    else % shouldn't happen
        chan_in = ndims(luttag.CLUT);
    end
else                           % lutBtoAType
    chan_in = size(luttag.PreShaper, 2);      % required field
    % should == 3 (PCS)
    if isempty(luttag.CLUT)
        chan_out = chan_in;
    elseif chan_in < ndims(luttag.CLUT)
        chan_out = size(luttag.CLUT, chan_in + 1);
    else % Gamut-alarm tag
        chan_out = 1;
    end
end

