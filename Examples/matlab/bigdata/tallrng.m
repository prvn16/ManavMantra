function oldState = tallrng(newState, generator)
%TALLRNG Control the random number generator used by tall array calculations.
%   TALLRNG('default') puts the settings of the random number generator
%   used by tall array calculations to their default values so that they
%   produce the same random numbers as if you restarted MATLAB.
%
%   TALLRNG('shuffle') seeds the random number generator used by tall array
%   calculations based on the current time.
%
%   TALLRNG(SEED) seeds the random number generator used by tall array
%   calculations to a specific value
%
%   TALLRNG(SEED,GENERATOR) or
%   TALLRNG('shuffle',GENERATOR) specify the type of the random number
%   generator used by tall array calculations. Only generators that support
%   streams and substreams can be used.
%
%   S = TALLRNG returns the current settings of the random number generator
%   used by tall array calculations. The settings are returned in a
%   structure S that can be used to subsequently restore the settings.
%
%   TALLRNG(S) restores the settings of the random number generator used by
%   tall array calculations back to the values captured previously by 
%   S = TALLRNG.
%
%   See also RNG, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.


if nargin == 0 || nargout > 0
    % With no inputs, settings will be returned even when there are no outputs
    oldState = matlab.bigdata.internal.getSetGlobalRandState();
end

if nargin > 0
    if isstruct(newState) && isscalar(newState)
        if nargin > 1
            error(message('MATLAB:rng:maxrhs'));
        elseif ~isempty(setxor(fieldnames(newState),{'Type','Seed','StreamIndex','Substream'}))
            throw(badSettingsException);
        end
        % Make sure it is a generator we can support for parallel
        checkSupportedGenerator(newState.Type);
        
        % Use RandStream to validate the inputs
        try
            rs = matlab.bigdata.internal.rngState2Randstream(newState);
        catch me
            throw(badSettingsException);
        end
        state = matlab.bigdata.internal.randstream2RNGState(rs);
        matlab.bigdata.internal.getSetGlobalRandState(state);
        
    elseif iIsScalarString(newState) && strcmpi(newState, 'default')
        if nargin > 1
            error(message('MATLAB:rng:maxrhs'));
        end
        s = matlab.bigdata.internal.createDefaultRandState();
        matlab.bigdata.internal.getSetGlobalRandState(s);
        
    elseif iIsScalarString(newState) && strcmpi(newState, 'shuffle')
        s = matlab.bigdata.internal.createDefaultRandState();
        s.Seed = uint32(RandStream.shuffleSeed);
        if nargin > 1
            checkSupportedGenerator(generator);
            % Always convert to the canonical name
            s.Type = RandStream.compatName(generator);
        end
        matlab.bigdata.internal.getSetGlobalRandState(s);
        
    elseif isnumeric(newState) && isscalar(newState)
        s = matlab.bigdata.internal.createDefaultRandState();
        if nargin > 1
            checkSupportedGenerator(generator);
            s.Type = char(generator); % Just in case it was a string
        end
        checkSeed(s.Type, newState)
        s.Seed = uint32(newState);
        matlab.bigdata.internal.getSetGlobalRandState(s);
        
    else
        error(message('MATLAB:rng:badFirstOpt'));
    end
end
end

function tf = iIsScalarString(arg)
% True if the input is a char array or a scalar string
tf = ischar(arg) || (isstring(arg) && isscalar(arg));
end

function checkSupportedGenerator(type)
% Is the named type supported? Only generators that allow substreams are
% allowed. Throws an error if not.
if ~any(strcmpi(RandStream.algName(type), {'mrg32k3a', 'mlfg6331_64'}))
    throwAsCaller(MException(message('MATLAB:bigdata:randstream:UnsupportedRNGType', type)));
end
end

function checkSeed(gentype, seed)
% Is the seed specified valid? Throws an error if not.

% To avoid duplicating logic, just get RandStream to check
try
    RandStream(gentype,'Seed',seed);
catch me
    throwAsCaller(MException(message('MATLAB:rng:badSeed')));
end

end

function e = badSettingsException
e = MException(message('MATLAB:bigdata:randstream:RNGBadSettings'));
end