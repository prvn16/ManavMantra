function [peaksnr,snr] = psnr(A,ref,peakval_user) %#codegen

% Copyright 2015 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(2,3);

checkImages(A,ref);

if nargin < 3
    peakval = diff(getrangefromclass(A));
else
    checkPeakval(peakval_user,A);
    peakval = double(peakval_user);
end

if isa(ref,'single')
    % if the input is single, return a single
    classToUse = 'single';
else
    % otherwise, do the computation in double precision
    classToUse = 'double';
end

if isempty(A) % If A is empty, ref must also be empty
    peaksnr = cast([],classToUse);
    snr     = cast([],classToUse);
    return;
end

if nargout > 1
    % for better performance, do only one pass through the data and compute
    % the MSE and the mean square simultaneously, instead of calling immse
    meanSquareError = cast(0,classToUse);
    meanSquare = cast(0,classToUse);
    
    numElems = numel(A);
    for i=1:numElems
        % pixel values in input images
        val    = cast(A(i),classToUse);
        refVal = cast(ref(i),classToUse);
        % compute the mean square error between A and the reference image
        meanSquareError = meanSquareError + (val-refVal)*(val-refVal);
        % compute mean square of the reference image
        meanSquare = meanSquare + refVal*refVal;
    end
    meanSquareError = meanSquareError / cast(numElems,classToUse);
    meanSquare      = meanSquare / cast(numElems,classToUse);
    
    snr = 10*log10(meanSquare/meanSquareError);
else
    % if we are only returning the peak SNR, then simply call immse; we
    % can't optimize the perf any more
    meanSquareError = immse(A,ref);
end

peaksnr = 10*log10(peakval*peakval/meanSquareError);

end

function checkImages(A, ref)

validImageTypes = {'uint8','uint16','int16','single','double'};

validateattributes(A,validImageTypes,{'nonsparse'},mfilename,'A',1);
validateattributes(ref,validImageTypes,{'nonsparse'},mfilename,'REF',2);

% A and ref must be of the same class
coder.internal.errorIf(~isa(A,class(ref)),'images:validate:differentClassMatrices','A','REF');

% A and ref must have the same size
coder.internal.errorIf(~isequal(size(A),size(ref)),'images:validate:unequalSizeMatrices','A','REF');

end

function checkPeakval(peakval, A)

validateattributes(peakval,{'numeric'},{'nonnan', 'real', ...
    'nonnegative','nonsparse','nonempty','scalar'}, mfilename, ...
    'PEAKVAL',3);

if isinteger(A) && (peakval > diff(getrangefromclass(A)))
    coder.internal.warning('images:psnr:peakvalTooLarge','A','REF');
end

end