function out = applyparametric(in, funtype, isfwd, funparams)
%APPLYPARAMETRIC processes data through tags of parametricCurveType
%   OUT = APPLYPARAMETRIC(IN, FUNTYPE, ISFWD, FUNPARAMS)
%   remaps the input vector IN through a closed-form expression to
%   compute the output vector OUT.  The form of the function is
%   specified by FUNTYPE, which is an integer in [0, 4], and can
%   be applied in either the forward or inverse sense, depending
%   on the value of the logical variable ISFWD.  IN and OUT are
%   scaled to the interval [0.0, 1.0].  FUNPARAMS is a double array
%   providing the required function parameters, which depend on 
%   the FUNTYPE as follows:
%
%   FUNTYPE 0 requires GAMMA
%           1          GAMMA, A, B
%           2          GAMMA, A, B, C
%           3          GAMMA, A, B, C, D
%           4          GAMMA, A, B, C, D, E, F
%
%   as defined in Section 10.15 (parametricCurveType) of the
%   ICC specification ICC.1:2004-10 (Profile version 4.2.0.0).

%   Copyright 2005-2015 The MathWorks, Inc.
%   Author:  Robert Poe 10/15/05

validateattributes(in, {'double'}, ...
              {'real', 'vector', 'nonsparse', 'nonnegative', 'finite'}, ...
              'applyparametric', 'IN', 1);
validateattributes(funtype, {'double'}, {'real', 'scalar', 'nonnegative'}, ...
              'applyparametric', 'FUNTYPE', 2);
validateattributes(isfwd, {'logical'}, {'scalar'}, ...
              'applyparametric', 'ISFWD', 3);
validateattributes(funparams, {'double'}, {'real', 'vector', 'finite'}, ...
              'applyparametric', 'FUNPARAMS', 4);
          
if isempty(funparams)
    error(message('images:applyparametric:numParams'))
end
plength = length(funparams);
if funparams(1) < 0
    error(message('images:applyparametric:negativeGamma'))
end

% Evaluate specified function (assume 0 <= in <= 1)
switch funtype
    case 0
        gamma = funparams(1);
        if isfwd
            out = real(in .^ gamma);
        else
            if gamma == 0.0
                out = zeros(size(in));
            else
                out = real(in .^ (1.0 / gamma));
            end
        end        
        
    case 1
        if plength < 3
            error(message('images:applyparametric:numParams'))
        end
        gamma = funparams(1);
        a = funparams(2);
        b = funparams(3);
        if isfwd
            out = zeros(size(in));
            base = a * in + b * ones(size(in));
            if a == 0.0
                inrange = find(in >= 0.0);
            else
                inrange = find(in > - b / a);
            end
            out(inrange) = real(base(inrange) .^ gamma);
        else
            if a ~= 0.0 && gamma ~= 0.0
                out = (1.0 / a) * (real(in .^ (1.0 / gamma)) - b);
            else
                out = zeros(size(in));
            end
        end
        
    case 2
        if plength < 4
            error(message('images:applyparametric:numParams'))
        end
        gamma = funparams(1);
        a = funparams(2);
        b = funparams(3);
        c = funparams(4);
        if isfwd
            out = c * ones(size(in));
            base = a * in + b * ones(size(in));
            if a == 0.0
                inrange = find(in >= 0.0);
            else
                inrange = find(in >= -b / a);
            end
            out(inrange) = real(base(inrange) .^ gamma) + out(inrange);
        else
            if a ~= 0.0 && gamma ~= 0.0
                out = (1.0 / a) * (real((in - c) .^ (1.0 / gamma)) - b);
            else
                out = zeros(size(in));
            end
        end

    case 3
        if plength < 5
            error(message('images:applyparametric:numParams'))
        end
        gamma = funparams(1);
        a = funparams(2);
        b = funparams(3);
        c = funparams(4);
        d = funparams(5);
        if isfwd
            out = c * in;
            base = a * in + b * ones(size(in));
            inrange = find(in >= d);
            out(inrange) = real(base(inrange) .^ gamma);
        else
            if c ~= 0.0
                out = (1 / c) * in;
            else
                out = d * ones(size(in));
            end
            inrange = find(out >= d);          
            if a ~= 0.0 && gamma ~= 0.0
                out(inrange) = ...
                    (1.0 / a) * (real(in(inrange) .^ (1.0 / gamma)) - b);
            else
                out(inrange) = d;
            end
        end
        
    case 4
        if plength < 7
            error(message('images:applyparametric:numParams'))
        end
        gamma = funparams(1);
        a = funparams(2);
        b = funparams(3);
        c = funparams(4);
        d = funparams(5);
        e = funparams(6);
        f = funparams(7);
        if isfwd
            out = c * in + f;
            base = a * in + b * ones(size(in));
            inrange = find(in >= d);
            out(inrange) = real(base(inrange) .^ gamma) + e;
        else
            if c ~= 0.0
                out = (in - f) / c;
            else
                out = d * ones(size(in));
            end
            inrange = find(out >= d);
            if a ~= 0.0 && gamma ~= 0.0
                out(inrange) = ...
                 (1.0 / a) * (real((in(inrange) - e) .^ (1.0 / gamma)) - b);
            else
                out(inrange) = d;
            end
        end

    otherwise
        error(message('images:applyparametric:functionType'))
    
end    
