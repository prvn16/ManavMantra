function B = labeloverlay(varargin)
%LABELOVERLAY Overlay label matrix regions on a 2-D image.
%   B = LABELOVERLAY(A,L) fills the input image with a different solid
%   color for each label in the label matrix L. L must be a valid MxN label matrix
%   that agrees with the size of A.
%
%   B = LABELOVERLAY(A,BW) fills the input image with a solid color where
%   BW is true. BW must be a valid mask that agrees with the size of A.
%
%   B = LABELOVERLAY(A,C) fills in the input image with a different solid
%   color for each label specified by the categorical matrix C. C 
%
%   B = LABELOVERLAY(___,NAME,VALUE) computes the fused overlay image B
%   using NAME/VALUE parameters to control aspects of the computation.
%
%   Parameters include:
%
%   'Colormap'              Mx3 colormap where M is the number of labels in
%                           the label matrix L or binary mask BW. RGB
%                           triplets in each row of the colormap must be
%                           normalized to the range [0,1]. A string or
%                           character vector corresonding to one of the
%                           valid inputs to the MATLAB colormap function is
%                           also accepted, in which case a permuted form of
%                           the specified colormap suitable for labeled
%                           region visualization will be used.
%
%                           Default: 'jet'
%
%   'IncludedLabels'        Scalar or vector of integer values in the range
%                           [1,max(L(:))] that specify the labels that will
%                           be falsecolored and blended with the input
%                           image. When a categorical, C, is provided as
%                           the specification of the labeled regions,
%                           'IncludedLabels' can also be a vector of
%                           strings corresponding to labels in C.
%
%                           Default: 1:length(L(:))
%
%   'Transparency'          Scalar numeric value in the range [0,1] that
%                           controls the blending of the label matrix with
%                           the original input image A. A value of 1.0
%                           makes the label matrix coloring completely
%                           transparent. A value of 0.0 makes the label
%                           matrix coloring completely opaque.
%
%                           Default: 0.5
%
%   Class Support
%   -------------
%   The input image A is of type uint8, uint16, single,
%   double, logical, or int16. The input label matrix L is a numeric
%   matrix. B is an RGB image of type uint8.
%
%   Example 1 - Visualize over-segmentation of RGB data
%   ---------
%    A = imread('kobi.png');
%    [L,N] = superpixels(A,20);
%    figure
%    imshow(labeloverlay(A,L));
%
%   Example 2 - Visualize binary-segmentation of greyscale image
%   ---------
%   A = imread('coins.png');
%   t = graythresh(A);
%   BW = imbinarize(A,t);
%   figure
%   imshow(labeloverlay(A,BW))
%
%   Example 3 - Visualize segmentation specified as categorical array
%   ---------
%   A = imread('coins.png');
%   t = graythresh(A);
%   BW = imbinarize(A,t);
%   stringArray = repmat("table",size(BW));
%   stringArray(BW) = "coin";
%   categoricalSegmentation = categorical(stringArray);
%   figure
%   imshow(labeloverlay(A,categoricalSegmentation,'IncludedLabels',"coin"));
%
%   See also superpixels, imoverlay

%   Copyright 2017 The MathWorks, Inc.

narginchk(2,inf);

parsedInputs = parseInputs(varargin{:});

A = parsedInputs.A;
L = parsedInputs.L;
cmap = parsedInputs.Colormap;
includeList = parsedInputs.IncludedLabels;
alpha = 1-parsedInputs.Transparency;

B = images.internal.labeloverlayalgo(A,L,cmap,alpha,includeList);

B = im2uint8(B);

end

function cmapOut = formPermutedColormap(cmap)
% Create run-to-run reproducible shuffled version of the specified
% colormap. When viewing labeled regions, you don't want nearby regions to
% have similar colors. Many of the built-in colormaps take a path through
% some colorspace, so nearby elements in colormaps tend to have similar
% colors, which we don't want.

s = rng;
c = onCleanup(@() rng(s));
rng('default');
maxLabel = size(cmap,1);
cmapOut = cmap(randperm(maxLabel),:);

end

function results = parseInputs(varargin)

A = varargin{1};
L = varargin{2};

allowedTypes = images.internal.iptnumerictypes();
allowedTypes{end+1} = 'logical';
allowedTypes{end+1} = 'categorical';
validateattributes(A,{'single', 'double', 'uint8', 'uint16', 'int16'},{'nonsparse','real','nonempty'},mfilename,'A');
isGrayOrRGBImage = ismatrix(A) || ((ndims(A) == 3) && (size(A,3) == 3));
if ~isGrayOrRGBImage
    error(message('images:labeloverlay:inputImageMustBeGrayOrRGB'));
end

validateattributes(L,allowedTypes,{}); % Just do type checking to start.

if ~iscategorical(L)
    Ldouble = double(L);
    maxLabel = max(Ldouble(:));
else
    Ldouble = double(uint32(L));
    maxLabel = length(categories(L));
end

validateattributes(Ldouble,allowedTypes,{'integer','nonsparse','real','nonnegative','nonempty','ndims',2},mfilename);

A = im2single(A);

% Function scoped variables used in input parsing
cmapFunctionScope = formPermutedColormap(jet(maxLabel));

parser = inputParser();
parser.addParameter('Transparency',0.5,@validateTransparency);
parser.addParameter('IncludedLabels',1:maxLabel,@validateIncludedLabels);
parser.addParameter('Colormap',cmapFunctionScope,@validateColormap);

parser.parse(varargin{3:end})

results = parser.Results;
results.IncludedLabels = postProcessIncludedLabels(L,results.IncludedLabels);

results.A = A;
results.L = Ldouble;
results.MaxLabel = maxLabel;
results.IncludedLabels = double(results.IncludedLabels);
results.Colormap = single(cmapFunctionScope);
results.Transparency = single(results.Transparency);

if size(results.Colormap,1) < maxLabel
    error(message('images:labeloverlay:badColormap'));
end

if (max(results.IncludedLabels(:)) > maxLabel) 
   error(message('images:labeloverlay:badBackgroundLabel')); 
end

sizeA = size(A);
if ~isequal(size(L), sizeA(1:2))
   error(message('images:labeloverlay:inputImageSizesDisagree'));
end

    function TF = validateTransparency(transparency)
        validateattributes(transparency,{'single','double'},{'real','scalar','nonsparse','<=',1,'>=',0},mfilename,'Transparency');
        TF = true;
    end

    function TF = validateColormap(cmap)
        if isnumeric(cmap)
            validateattributes(cmap,{'single','double'},{'real','2d','nonsparse','ncols',3,'<=',1,'>=',0},mfilename,'Colormap');
            cmapFunctionScope = cmap;
        else
            try
               cmapTemp = feval(cmap,maxLabel);
               cmapFunctionScope = formPermutedColormap(cmapTemp);
            catch
                error(message('images:labeloverlay:invalidColormapString'));
            end
        end
        TF = true;
    end

    function TF = validateIncludedLabels(includedLabels)
        
        validTypes = images.internal.iptnumerictypes();
        if isnumeric(includedLabels)
            validateattributes(includedLabels,validTypes,...
                {'real','vector','nonsparse','integer','positive'},mfilename,'IncludedLabels');
        end
        
        TF = true;
    end

end

function includedLabels = postProcessIncludedLabels(C,includedLabels)

if iscategorical(C) && isstring(includedLabels)
    if all(iscategory(C,includedLabels))
        categoriesSet = string(categories(C));
        includedLabelsOut = zeros([1 length(includedLabels)]);
        for i = 1:length(includedLabels)
           includedLabelsOut(i) = find(includedLabels(i) == categoriesSet);
        end
        includedLabels = includedLabelsOut;
    else
        error(message('images:labeloverlay:invalidCategory')); 
    end
end

end



