function bfitSetListenerEnabled(L, state)
%BFITSETLISTENERENABLED   Set the enabled state for a listener
%
%   BFITSETLISTENERENABLED(L, STATE) sets the enabled state of the listener L.
%   STATE is a logical scalar.

%   Copyright 2008-2014 The MathWorks, Inc.
%        

% Safe way to set the Enabled property of a listener
L.Enabled = state;
