function y = tanh(u) %#codegen
    %TANH Computes the hyperbolic tangent for the input argument
    % (specified in hyperbolic radians).
    
    %   Copyright 2017 The MathWorks, Inc
    
    %----------------------------------------------------------------------  
    y = cordictanh(u);
end