function cb = bfitCallbackFunction(fcn, varargin)
%BFITCALLBACKFUNCTION    Function for use in callbacks
%
%   CB = BFITCALLBACKFUNCTION(FCN, ...)  is a object that can be used as a callback.
%
%   Essentially, this function takes the variable part of the argument list and
%   passes them into the function, FCN, after the source and event.

%   Copyright 2008 The MathWorks, Inc.

cb = @callback;

    function callback( src, evt )
        fcn( src, evt, varargin{:} );
    end
end
