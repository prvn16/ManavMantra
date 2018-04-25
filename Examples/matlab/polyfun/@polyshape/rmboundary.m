function PG = rmboundary(pshape, I, varargin)
% RMBOUNDARY Remove boundary in polyshape
%
% PG = RMBOUNDARY(pshape, I) removes the I-th boundary of a polyshape.
%
% PG = RMBOUNDARY(..., 'Simplify', tf) specifies how ill-defined polyshape 
% boundaries are handled. tf can be one of the following:
%  true (default) - Automatically alter boundary vertices or directions to 
% create a well-defined polygon.
%  false - Do not alter boundary vertices even though the polyshape is 
% ill-defined. This may lead to inaccurate or unexpected results.
%
% See also addboundary, numboundaries, rmholes, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2, inf);

polyshape.checkScalar(pshape);
polyshape.checkEmpty(pshape);

II = polyshape.checkIndex(pshape, I);

ninputs = numel(varargin);
if mod(ninputs, 2) ~= 0
    error(message('MATLAB:polyshape:nameValuePairError'));
end

simpl = "default";
for k = 1:2:ninputs
    if ischar(varargin{k}) || isstring(varargin{k})
        name = char(varargin{k});
        nn = max(length(name), 1);
        if strncmpi(name, 'simplify', nn)
            next_arg = varargin{k+1};
            if isscalar(next_arg) && (islogical(next_arg) || isnumeric(next_arg))
                if double(next_arg) == 1
                    simpl = "true";
                elseif double(next_arg) == 0
                    simpl = "false";
                else
                    error(message('MATLAB:polyshape:simplifyValue'));
                end
            else
                error(message('MATLAB:polyshape:simplifyValue'));
            end
        else
            error(message('MATLAB:polyshape:rmBoundaryParameter'));
        end
    else
        error(message('MATLAB:polyshape:rmBoundaryParameter'));
    end
end

PG = pshape;
PG.Underlying = rmboundary(pshape.Underlying, II);

if simpl == "true" || (simpl == "default" && ...
                       pshape.SimplifyState >= 0)
    PG = checkAndSimplify(PG, true);
    PG.SimplifyState = 1;
else
    PG.SimplifyState = -1;
end
