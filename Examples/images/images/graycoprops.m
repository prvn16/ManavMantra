function stats = graycoprops(varargin)
%GRAYCOPROPS Properties of gray-level co-occurrence matrix.  
%   STATS = GRAYCOPROPS(GLCM,PROPERTIES) normalizes the gray-level
%   co-occurrence matrix (GLCM) so that the sum of its elements is one. Each
%   element in the normalized GLCM, (r,c), is the joint probability occurrence
%   of pixel pairs with a defined spatial relationship having gray level
%   values r and c in the image. GRAYCOPROPS uses the normalized GLCM to
%   calculate PROPERTIES.
%
%   GLCM can be an m x n x p array of valid gray-level co-occurrence
%   matrices. Each gray-level co-occurrence matrix is normalized so that its
%   sum is one.
%
%   PROPERTIES can be a comma-separated list of strings or char vectors, a
%   cell array containing strings or char vectors, the string "all", char
%   vector 'all', or a space separated string or char vector. They can be
%   abbreviated, and case does not matter.
%
%   Properties include:
%  
%   'Contrast'      the intensity contrast between a pixel and its neighbor 
%                   over the whole image. Range = [0 (size(GLCM,1)-1)^2]. 
%                   Contrast is 0 for a constant image.
%
%   'Correlation'   statistical measure of how correlated a pixel is to its 
%                   neighbor over the whole image. Range = [-1 1]. 
%                   Correlation is 1 or -1 for a perfectly positively or
%                   negatively correlated image. Correlation is NaN for a 
%                   constant image.
%
%   'Energy'        summation of squared elements in the GLCM. Range = [0 1].
%                   Energy is 1 for a constant image.
%  
%   'Homogeneity'   closeness of the distribution of elements in the GLCM to
%                   the GLCM diagonal. Range = [0 1]. Homogeneity is 1 for
%                   a diagonal GLCM.
%  
%   If PROPERTIES is the string "all" or char vector 'all', then all of the
%   above properties are calculated. This is the default behavior. Please
%   refer to the Documentation for more information on these properties.
%  
%   STATS is a structure with fields that are specified by PROPERTIES. Each
%   field contains a 1 x p array, where p is the number of gray-level
%   co-occurrence matrices in GLCM. For example, if GLCM is an 8 x 8 x 3 array
%   and PROPERTIES is 'Energy', then STATS is a structure containing the
%   field 'Energy'. This field contains a 1 x 3 array.
%
%   Notes
%   -----  
%   Energy is also known as uniformity, uniformity of energy, and angular second
%   moment.
%
%   Contrast is also known as variance and inertia.
%
%   Class Support
%   -------------  
%   GLCM can be logical or numeric, and it must contain real, non-negative, finite,
%   integers. STATS is a structure.
%
%   Examples
%   --------
%   GLCM = [0 1 2 3;1 1 2 3;1 0 2 0;0 0 0 3];
%   stats = graycoprops(GLCM)
%
%   I = imread('circuit.tif');
%   GLCM2 = graycomatrix(I,'Offset',[2 0;0 2]);
%   stats = graycoprops(GLCM2,{'contrast','homogeneity'})
%  
%   See also GRAYCOMATRIX.

% Copyright 2003-2016 The MathWorks, Inc.

allStats = {'Contrast','Correlation','Energy','Homogeneity'};
  
[glcm, requestedStats] = ParseInputs(allStats, varargin{:});

% Initialize output stats structure.
numStats = length(requestedStats);
numGLCM = size(glcm,3);
empties = repmat({zeros(1,numGLCM)},[numStats 1]);
stats = cell2struct(empties,requestedStats,1);

for p = 1 : numGLCM
  
  if numGLCM ~= 1 %N-D indexing not allowed for sparse. 
    tGLCM = normalizeGLCM(glcm(:,:,p));
  else 
    tGLCM = normalizeGLCM(glcm);
  end
  
  % Get row and column subscripts of GLCM.  These subscripts correspond to the
  % pixel values in the GLCM.
  s = size(tGLCM);
  [c,r] = meshgrid(1:s(1),1:s(2));
  r = r(:);
  c = c(:);

  % Calculate fields of output stats structure.
  for k = 1:numStats
    name = requestedStats{k};  
    switch name
     case 'Contrast'
      stats.(name)(p) = calculateContrast(tGLCM,r,c);
      
     case 'Correlation'
      stats.(name)(p) = calculateCorrelation(tGLCM,r,c);
      
     case 'Energy'
      stats.(name)(p) = calculateEnergy(tGLCM);
      
     case 'Homogeneity'
      stats.(name)(p) = calculateHomogeneity(tGLCM,r,c);
    end
  end

end


%-----------------------------------------------------------------------------
function glcm = normalizeGLCM(glcm)
  
% Normalize glcm so that sum(glcm(:)) is one.
if any(glcm(:))
  glcm = glcm ./ sum(glcm(:));
end
  
%-----------------------------------------------------------------------------
function C = calculateContrast(glcm,r,c)
% Reference: Haralick RM, Shapiro LG. Computer and Robot Vision: Vol. 1,
% Addison-Wesley, 1992, p. 460.  
k = 2;
l = 1;
term1 = abs(r - c).^k;
term2 = glcm.^l;
  
term = term1 .* term2(:);
C = sum(term);

%-----------------------------------------------------------------------------
function Corr = calculateCorrelation(glcm,r,c)
% References: 
% Haralick RM, Shapiro LG. Computer and Robot Vision: Vol. 1, Addison-Wesley,
% 1992, p. 460.
% Bevk M, Kononenko I. A Statistical Approach to Texture Description of Medical
% Images: A Preliminary Study., The Nineteenth International Conference of
% Machine Learning, Sydney, 2002. 
% http://www.cse.unsw.edu.au/~icml2002/workshops/MLCV02/MLCV02-Bevk.pdf, p.3.
  
% Correlation is defined as the covariance(r,c) / S(r)*S(c) where S is the
% standard deviation.

% Calculate the mean and standard deviation of a pixel value in the row
% direction direction. e.g., for glcm = [0 0;1 0] mr is 2 and Sr is 0.
mr = meanIndex(r,glcm);
Sr = stdIndex(r,glcm,mr);
  
% mean and standard deviation of pixel value in the column direction, e.g.,
% for glcm = [0 0;1 0] mc is 1 and Sc is 0.
mc = meanIndex(c,glcm);
Sc = stdIndex(c,glcm,mc);

term1 = (r - mr) .* (c - mc) .* glcm(:);
term2 = sum(term1);

Corr = term2 / (Sr * Sc);

%-----------------------------------------------------------------------------
function S = stdIndex(index,glcm,m)

term1 = (index - m).^2 .* glcm(:);
S = sqrt(sum(term1));

%-----------------------------------------------------------------------------
function M = meanIndex(index,glcm)

M = index .* glcm(:);
M = sum(M);

%-----------------------------------------------------------------------------
function E = calculateEnergy(glcm)
% Reference: Haralick RM, Shapiro LG. Computer and Robot Vision: Vol. 1,
% Addison-Wesley, 1992, p. 460.  
  
foo = glcm.^2;
E = sum(foo(:));

%-----------------------------------------------------------------------------
function H = calculateHomogeneity(glcm,r,c)
% Reference: Haralick RM, Shapiro LG. Computer and Robot Vision: Vol. 1,
% Addison-Wesley, 1992, p. 460.  
  
term1 = (1 + abs(r - c));
term = glcm(:) ./ term1;
H = sum(term);

%-----------------------------------------------------------------------------
function [glcm,reqStats] = ParseInputs(allstats,varargin)
  
numstats = length(allstats);
narginchk(1,numstats+1);

reqStats = '';
glcm = varargin{1};

% The 'nonnan' and 'finite' attributes are not added to validateattributes because the
% 'integer' attribute takes care of these requirements.
validateattributes(glcm,{'logical','numeric'},{'real','nonnegative','integer'}, ...
              mfilename,'GLCM',1);

if ndims(glcm) > 3
  error(message('images:graycoprops:invalidSizeForGLCM'))
end

% Cast GLCM to double to avoid truncation by data type. Note that GLCM is not an
% image.
if ~isa(glcm,'double')
  glcm = double(glcm);
end

list = varargin(2:end);

if isempty(list)
  % GRAYCOPROPS(GLCM) or GRAYCOPROPS(GLCM,PROPERTIES) where PROPERTIES is empty.
  reqStats = allstats;
else
  if iscell(list{1}) || numel(list) == 1
    % GRAYCOPROPS(GLCM,{...})
    list = list{1};
  end

  if ischar(list)
    %GRAYCOPROPS(GLCM,SPACE-SEPARATED STRING)
    C = textscan(list, '%s');
    list = C{1};
  end

  anyprop = allstats;
  anyprop{end+1} = 'all';
  
  for k = 1 : length(list)
    match = validatestring(list{k}, anyprop, mfilename, 'PROPERTIES', k+1);
    if strcmp(match,'all')
      reqStats = allstats;
      break;
    end
    reqStats{k} = match;
  end
  
end

% Make sure that reqStats are in alphabetical order.
reqStats = sort(reqStats);

if isempty(reqStats)
  error(message('images:graycoprops:internalError'))
end
