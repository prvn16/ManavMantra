function [return1,return2] = spparms(arg1,arg2)
%SPPARMS Set parameters for sparse matrix routines.
%   SPPARMS('key',value) sets one or more of the "tunable" parameters 
%   used in the sparse routines, particularly sparse / and \.
%
%   SPPARMS, by itself, prints a description of the current settings.
%
%   If no input argument is present, values = SPPARMS returns a
%   vector whose components give the current settings.
%   [keys,values] = SPPARMS returns that vector, and also returns
%   a character matrix whose rows are the keywords for the parameters.
%
%   SPPARMS(values), with no output argument, sets all the parameters
%   to the values specified by the argument vector.
%
%   value = SPPARMS('key') returns the current setting of one parameter.
%
%   SPPARMS('default') sets all the parameters to their default settings.
%   SPPARMS('tight') sets the minimum degree ordering parameters to their 
%   "tight" settings, which may lead to orderings with less fill-in, but 
%   which makes the ordering functions themselves use more execution time.
%
%   The parameters with the default and "tight" values are:
%
%                    keyword       default       tight
%
%      values(1)     'spumoni'      0
%      values(2)     'thr_rel'      1.1          1.0
%      values(3)     'thr_abs'      1.0          0.0
%      values(4)     'exact_d'      0            1
%      values(5)     'supernd'      3            1
%      values(6)     'rreduce'      3            1
%      values(7)     'wh_frac'      0.5          0.5
%      values(8)     'autommd'      1            
%      values(9)     'autoamd'      1
%      values(10)    'piv_tol'      0.1
%      values(11)    'bandden'      0.5
%      values(12)    'umfpack'      1
%      values(13)    'sym_tol'      0.001
%      values(14)    'ldl_tol'      0.01
%
%   The meanings of the parameters are
%
%      spumoni:  The Sparse Monitor Flag controls diagnostic output;
%                0 means none, 1 means some, 2 means too much.
%      thr_rel,
%      thr_abs:  Minimum degree threshold is thr_rel*mindegree + thr_abs.
%      exact_d:  Nonzero to use exact degrees in minimum degree,
%                Zero to use approximate degrees.
%      supernd:  If > 0, MMD amalgamates supernodes every supernd stages.
%      rreduce:  If > 0, MMD does row reduction every rreduce stages.
%      wh_frac:  Rows with density > wh_frac are ignored in COLMMD.
%      autommd:  Nonzero to use SYMMMD and COLMMD orderings with \ and /.
%      autoamd:  Nonzero to use AMD or COLAMD ordering with CHOLMOD, UMFPACK,
%                and SuiteSparseQR in \ and /.
%      piv_tol:  Pivot tolerance used by LU-based (UMFPACK) \ and /.
%      bandden:  Backslash uses band solver if band density is > bandden.
%                If bandden = 1.0, never use band solver.
%                If bandden = 0.0, always use band solver.
%      umfpack:  Nonzero to use UMFPACK instead of the v4 LU-based solver
%                in \ and /.
%      sym_tol:  Symmetric pivot tolerance used by UMFPACK.  See LU for
%                more information about the role of the symmetric pivot
%                tolerance.
%      ldl_tol:  Pivot tolerance used by LDL-based (MA57) \ and /.
%
%   Note:
%   Solving symmetric positive definite matrices within \ and /:
%      The CHOLMOD CHOL-based solver uses AMD.
%   Solving general square matrices within \ and /:
%      The UMFPACK LU-based solver uses either AMD or a modified COLAMD.
%      The v4 LU-based solver uses COLMMD.
%   Solving rectangular matrices within \ and /:
%      The SuiteSparseQR QR-based solver uses COLAMD.
%   All of these algorithms respond to SPPARMS('autoamd') except for the
%   v4 LU-based, which responds to SPPARMS('autommd').
%
%   See also AMD, COLAMD, SYMAMD.

%   Copyright 1984-2017 The MathWorks, Inc.

% The following are "constants".

allkeys = ['spumoni'
           'thr_rel'
           'thr_abs'
           'exact_d'
           'supernd'
           'rreduce'
           'wh_frac'
           'autommd'
           'autoamd'
           'piv_tol'
           'bandden'
           'umfpack'
           'sym_tol'
           'ldl_tol'
           'usema57'
           'spqrtol'
           'chmodsp'
           'use_mts'];
nparms = size(allkeys,1);
spuparmrange = 1:1;   % Which parameters pertain to SPUMONI?
mmdparmrange = 2:7;   % Which parameters pertain to minimum degree?
bslparmrange = [8:16,18];  % Which parameters pertain to sparse backslash?
cspparmrange = 17:17;
defaultparms = [0 1.1 1.0 0 3 3 0.5 1 1 0.1 0.5 1 0.001 0.01 1 -2 0 0]';
tightmmdparms   = [1.0 0.0 1 1 1 0.5]';

% First find out what the current parameters are.

oldvalues = zeros(nparms,1);
oldvalues(spuparmrange) = sparsfun('spumoni');
oldvalues(mmdparmrange) = sparsfun('mmdset');
oldvalues(bslparmrange) = sparsfun('slashset');
oldvalues(cspparmrange) = sparsfun('chmodsp');

% No input args, no output args:  Describe current settings.
if nargin == 0 && nargout == 0
    a = num2str(oldvalues(1));
    if oldvalues(1) 
      fprintf('%s',getString(message('MATLAB:spparms:SparseMonitorOutputLevel', a)));
    else 
      fprintf('%s',getString(message('MATLAB:spparms:NoSparseMonitorOutput')));
    end
    a = num2str(oldvalues(2));
    b = num2str(oldvalues(3));
    fprintf('%s',getString(message('MATLAB:spparms:MmdThreshold', a, b)));
    if oldvalues(4) 
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:UsingExactDegreesInAprimeA')));
    else 
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:UsingApproximateDegreesInAprimeA')));
    end
    s = int2str(oldvalues(5));
    if oldvalues(5)
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:SupernodeAmalgamationEveryNStages', s)));
    else
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:NoSupernodeAmalgamation')));
    end
    s = int2str(oldvalues(6));
    if oldvalues(6) 
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:RowReductionEveryNStages', s)));
    else
        fprintf('     ');
        fprintf(getString(message('MATLAB:spparms:NoRowReductionn')));
    end
    a = num2str(100*oldvalues(7));
    if oldvalues(7)
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:WithholdRowsAtLeastNPercentDenseInColmmd', a)));
    else
        fprintf('     ');
        fprintf('%s',getString(message('MATLAB:spparms:NoRowWithholdingInColmmd')));
    end
    if oldvalues(8)
      fprintf('%s',getString(message('MATLAB:spparms:MinimumDegreeOrderingsUsedWithV4')));
    else
      fprintf('%s',getString(message('MATLAB:spparms:NoAutomaticOrderingsUsedWithV4')));
    end
    if oldvalues(9)
      fprintf('%s',getString(message('MATLAB:spparms:ApproximateMinimumDegreeOrderingsUsedCholmodUmfpack')));
    else
      fprintf('%s',getString(message('MATLAB:spparms:NoAutomaticOrderingsUsedWithCholmodUmfpack')));
    end
    if oldvalues(18)
        fprintf('%s',getString(message('MATLAB:spparms:MetisOrderingUsedMA57')));
    elseif oldvalues(9)
        fprintf('%s',getString(message('MATLAB:spparms:ApproximateMinimumDegreeOrderingUsedMA57')));
    else
        fprintf('%s',getString(message('MATLAB:spparms:NoOrderingUsedMA57')));
    end
    a = num2str(oldvalues(10));
    fprintf('%s',getString(message('MATLAB:spparms:PivotToleranceOfUsedByUMFPACK', a)));
    a = num2str(oldvalues(11));
    fprintf('%s',getString(message('MATLAB:spparms:BackslashUsesBandSolverIfBandDensityGT', a)));
    if oldvalues(12)
        fprintf('%s',getString(message('MATLAB:spparms:UMFPACKUsedForLu')));
    else
        fprintf('%s',getString(message('MATLAB:spparms:V4AlgorithmUsedForLu')));
    end
    a = num2str(oldvalues(13));
    fprintf('%s',getString(message('MATLAB:spparms:SymmetricPivotToleranceUsedByUMFPACK', a)));
    a = num2str(oldvalues(14));
    fprintf('%s',getString(message('MATLAB:spparms:PivotToleranceUsedByMA57', a)));
    return;

% No input args, one or two output args:  Return current settings.
elseif nargin == 0 && nargout > 0
    if nargout <= 1
        return1 = oldvalues;
    else
        return1 = allkeys;
        return2 = oldvalues;
    end
    return;

% One input arg of suitable size:  Reset all parameters.
elseif nargin == 1 && length(arg1) == nparms && min(size(arg1)) == 1
    if nargout > 0 
        error (message('MATLAB:spparms:TooManyOutputs'))
    end
    sparsfun('spumoni',arg1(spuparmrange));
    sparsfun('mmdset',arg1(mmdparmrange));
    sparsfun('slashset',arg1(bslparmrange));
    sparsfun('chmodsp',arg1(cspparmrange));
    return;

% Input arg 'tight':  Reset minimum degree parameters.
elseif nargin == 1 && strcmpi(arg1,'tight')
    if nargout > 0
        error (message('MATLAB:spparms:TooManyOutputs'))
    end
    newvalues = oldvalues;
    newvalues(mmdparmrange) = tightmmdparms;
    spparms(newvalues);
    return;

% Input arg 'default':  Reset all parameters.
elseif nargin == 1 && strcmpi(arg1,'default')
    if nargout > 0
        error (message('MATLAB:spparms:TooManyOutputs'))
    end
    spparms(defaultparms);
    return;

% One input arg:  Return one current setting.
elseif (nargin == 1)
    if ~ischar(arg1)
        error (message('MATLAB:spparms:OptionNotString'))
    end
    if nargout > 1
        error (message('MATLAB:spparms:TooManyOutputs'))
    end
    if size(arg1,1) > 1
        error (message('MATLAB:spparms:TooManyParamsPerKeyword'))
    end
    key = lower(arg1);
    for i = 1:nparms
        if strcmp (key, allkeys(i,:))
            return1 = oldvalues(i);
            return;
        end
    end
    error(message('MATLAB:spparms:UnknownKeyword', key));

% Two input args:  Reset some parameters.
else
    if ~ischar(arg1)
        error (message('MATLAB:spparms:OptionNotString'));
    end
    if nargout > 0
        error (message('MATLAB:spparms:TooManyOutputs'));
    end
    if size(arg1,1) ~= length(arg2)
        error (message('MATLAB:spparms:ParamsMismatchKeywords'));
    end
    newvalues = oldvalues;
    for k = 1:size(arg1,1)
        key = lower(arg1(k,:));
        value = arg2(k);
        found = 0;
        for i = 1:nparms
            if strcmp (key, allkeys(i,:))
                newvalues(i) = value;
                found = 1;
                break
            end
        end
        if ~found
            warning(message('MATLAB:spparms:UnknownKeyword', key));
        end
    end
    spparms(newvalues);
    return;
   
end
