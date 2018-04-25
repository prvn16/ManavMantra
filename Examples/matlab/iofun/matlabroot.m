%MATLABROOT Root directory of MATLAB installation.
%   S = MATLABROOT returns the name of the directory where the MATLAB software is
%   installed.
%
%   MATLABROOT is used to produce platform dependent paths to the various MATLAB and
%   toolbox directories.
%
%   Example
%      fullfile(matlabroot,'toolbox','matlab','general','')
%   produces a full path to the toolbox/matlab/general directory that is correct
%   for platform it's executed on.
%
%   See also FULLFILE, PATH, TEMPDIR, PREFDIR.

%   Copyright 1984-2016 The MathWorks, Inc.

