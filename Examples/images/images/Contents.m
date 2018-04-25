% Image Processing Toolbox
% Version 10.2 (R2018a) 06-Feb-2018
%
% Image Processing Apps.
%   colorThresholder      - Threshold color image.
%   dicomBrowser          - Explore collection of DICOM files.
%   imageBatchProcessor   - Process a folder of images.
%   imageBrowser          - Browse images using thumbnails.
%   imageRegionAnalyzer   - Explore and filter regions in binary image.
%   imageSegmenter        - Segment 2D grayscale or RGB image.
%   registrationEstimator - Register images using intensity-based, feature-based, and nonrigid techniques.
%   volumeViewer          - View volumetric image.
%
% Deep Learning based functionalities.
%   denoiseImage                - Denoise an image using deep neural network
%   denoisingImageDatastore     - Construct an image denoising datastore
%   denoisingNetwork            - Image denoising network
%   dnCNNLayers                 - Get DnCNN (Denoising CNN) network layers
%
% Image display, exploration, and visualization.
%   colorbar       - Display colorbar (MATLAB Toolbox).
%   colorcloud     - Display 3D color gamut in specified color space.
%   image          - Create and display image object (MATLAB Toolbox).
%   imagesc        - Scale data and display as image (MATLAB Toolbox).
%   immovie        - Make movie from multiframe image.
%   imoverlay      - Burn binary mask into a 2-D image.
%   implay         - Play movies, videos, or image sequences.
%   imshow         - Display image in Handle Graphics figure.
%   imtool         - Display image in the Image Tool.
%   montage        - Display multiple image frames as rectangular montage.
%   movie          - Play recorded movie frames (MATLAB Toolbox).
%   visboundaries  - Plot region boundaries.
%   viscircles     - Create circle.
%   warp           - Display image as texture-mapped surface.
%
% Image file I/O.
%   analyze75info       - Read metadata from header file of Mayo Analyze 7.5 data set.
%   analyze75read       - Read image file of Mayo Analyze 7.5 data set.
%   dicomanon           - Anonymize DICOM file.
%   dicomCollection     - Gather details about related series of DICOM files.
%   dicomdict           - Get or set active DICOM data dictionary.
%   dicomdisp           - Display DICOM file structure.
%   dicominfo           - Read metadata from DICOM message.
%   dicomlookup         - Find attribute in DICOM data dictionary.
%   dicomread           - Read DICOM image.
%   dicomreadVolume     - Construct volume from directory of DICOM images/slices.
%   dicomuid            - Generate DICOM Unique Identifier.
%   dicomwrite          - Write images as DICOM files.
%   dicom-dict.txt      - Text file containing DICOM data dictionary (2007).
%   dicom-dict-2005.txt - Text file containing DICOM data dictionary (2005).
%   dpxinfo             - Read metadata about DPX image.
%   dpxread             - Read DPX image.
%   hdrread             - Read Radiance HDR image.
%   hdrwrite            - Write Radiance HDR image.
%   makehdr             - Create high dynamic range image.
%   niftiinfo           - Read metadata from NIfTI file.
%   niftiread           - Read NIfTI image.
%   niftiwrite          - Write images as NIfTI files.
%   ImageAdapter        - Interface for image format I/O.
%   imfinfo             - Information about image file (MATLAB Toolbox).
%   imread              - Read image file (MATLAB Toolbox).
%   imwrite             - Write image file (MATLAB Toolbox).
%   interfileinfo       - Read metadata from Interfile files.
%   interfileread       - Read images from Interfile files.
%   isdicom             - Check if file is DICOM.
%   isnitf              - Check if file is NITF.
%   isrset              - Check if file is reduced-resolution dataset (R-Set).
%   nitfinfo            - Read metadata from NITF file.
%   nitfread            - Read NITF image.
%   rsetwrite           - Create reduced-resolution dataset (R-Set) from image file.
%   images.dicom.decodeUID      - Get information about Unique Identifier (UID).
%   images.dicom.parseDICOMDIR  - Extract metadata from DICOMDIR file.
%
% Image arithmetic.
%   imabsdiff      - Absolute difference of two images.
%   imadd          - Add two images or add constant to image.
%   imapplymatrix  - Linear combination of color channels.
%   imcomplement   - Complement image.
%   imdivide       - Divide two images or divide image by constant.
%   imlincomb      - Linear combination of images.
%   immultiply     - Multiply two images or multiply image by constant.
%   imsubtract     - Subtract two images or subtract constant from image.
%
% Geometric transformations.
%   affine2d       - Create 2-D affine transformation.
%   affine3d       - Create 3-D affine transformation.
%   checkerboard   - Create checkerboard image.
%   findbounds     - Find output bounds for geometric transformation.
%   fliptform      - Flip input and output roles of TFORM structure.
%   imcrop         - Crop image.
%   impyramid      - Image pyramid reduction and expansion.
%   imresize       - Resize image.
%   imresize3      - Resize volume.
%   imrotate       - Rotate image.
%   imrotate3      - Rotate volume.
%   imtransform    - Apply 2-D geometric transformation to image.
%   imwarp         - Apply geometric transformation to image.
%   makeresampler  - Create resampling structure.
%   maketform      - Create geometric transformation structure (TFORM).
%   projective2d   - Create 2-D projective transformation.
%   tformarray     - Apply geometric transformation to N-D array.
%   tformfwd       - Apply forward geometric transformation.
%   tforminv       - Apply inverse geometric transformation.
%   images.geotrans.Warper - Apply same geometric transformation to many images efficiently.
%
% Image registration.
%   cpstruct2pairs   - Convert CPSTRUCT to control point pairs.
%   cp2tform         - Infer geometric transformation from control point pairs.
%   cpcorr           - Tune control point locations using cross-correlation.
%   cpselect         - Control Point Selection Tool.
%   fitgeotrans      - Fit geometric transformation to control point pairs.
%   imfuse           - Composite of two images.
%   imregcorr        - Register two 2-D images using phase correlation.
%   imregdemons      - Estimate displacement field that aligns two 2-D or 3-D images.
%   imregister       - Spatially register two images using intensity metric optimization.
%   imregmtb         - Register 2-D images using median threshold bitmaps.
%   imregtform       - Estimate geometric transformation that registers two images using intensity metric optimization.
%   imregconfig      - Configurations for intensity-based registration.
%   imshowpair       - Compare differences between images.
%   normxcorr2       - Normalized two-dimensional cross-correlation.
%   registration.metric.MattesMutualInformation - Mattes mutual information configuration.
%   registration.metric.MeanSquares - Mean squares error metric configuration.
%   registration.optimizer.OnePlusOneEvolutionary - One plus one evolutionary configuration.
%   registration.optimizer.RegularStepGradientDescent - Regular step gradient descent configuration.
%
% Pixel values and statistics.
%   corr2          - 2-D correlation coefficient.
%   imcontour      - Create contour plot of image data.
%   imhist         - Display histogram of N-D image data.
%   impixel        - Pixel color values.
%   improfile      - Pixel-value cross-sections along line segments.
%   mean2          - Average or mean of matrix elements.
%   regionprops    - Measure properties of image regions.
%   regionprops3   - Measure properties of 3-D image regions.
%   std2           - Standard deviation of matrix elements.
%
% Image analysis.
%   bwboundaries    - Trace region boundaries in binary image.
%   bwtraceboundary - Trace object in binary image.
%   edge            - Find edges in intensity image.
%   edge3           - Find edges in 3-D intensity image.
%   hough           - Hough transform.
%   houghlines      - Extract line segments based on Hough transform.
%   houghpeaks      - Identify peaks in Hough transform.
%   imfindcircles   - Find circles using Circular Hough Transform.
%   imgradient      - Find the gradient magnitude and direction of an image.
%   imgradient3     - Find the 3-D gradient magnitude and direction of a volume.
%   imgradientxy    - Find the directional gradients of an image.
%   imgradientxyz   - Find the directional gradients of a volume.
%   qtdecomp        - Quadtree decomposition.
%   qtgetblk        - Get block values in quadtree decomposition.
%   qtsetblk        - Set block values in quadtree decomposition.
%
% Image quality.
%   brisque                     - Blind/Referenceless Image Spatial Quality Evaluator (brisque)
%   brisqueModel                - Construct BRISQUEModel object
%   displayColorPatch           - Display visual color reproduction as color patches.
%   esfrChart                   - Construct an esfrChart object from an image.
%   displayChart                - Display esfrChart with overlaid regions of interest.
%   fitbrisque                  - Fit a custom model for calculating Blind/referenceless image spatial quality evaluator (BRISQUE) no-reference image quality score
%   fitniqe                     - Fit a custom model for calculating Naturalness Image Quality
%   measureChromaticAberration  - Measure chromatic aberration using esfrChart.
%   measureColor                - Measure color reproduction using esfrChart.
%   measureIlluminant           - Estimate the scene illuminant using esfrChart.
%   measureNoise                - Measure noise using esfrChart.
%   measureSharpness            - Compute spatial frequency response using esfrChart.
%   niqe                        - Naturalness image quality evaluator (niqe) no-reference image quality score
%   niqeModel                   - Construct NIQEModel object
%   plotChromaticity            - Plot color reproduction on chromaticity diagram.
%   plotSFR                     - Plot spatial frequency response (SFR).
%   psnr                        - Peak Signal-To-Noise Ratio.
%   ssim                        - Structural Similarity Index for measuring image quality.
%
% Image enhancement.
%   adapthisteq    - Contrast-limited Adaptive Histogram Equalization (CLAHE).
%   decorrstretch  - Apply decorrelation stretch to multichannel image.
%   fibermetric    - Enhance elogated/tubular structures in images.
%   histeq         - Enhance contrast using histogram equalization.
%   imadjust       - Adjust image intensity values or colormap.
%   imadjustn      - Adjust 3-D image intensity values or colormap.
%   imbilatfilt    - Bilateral filtering of images with Gaussian kernels.
%   imdiffuseest   - Estimates parameters for imdiffusefilt.
%   imdiffusefilt  - Anisotropic diffusion filtering of images.
%   imguidedfilter - Guided filtering of images.
%   imhistmatch    - Adjust 2-D image to match its histogram to that of another image.
%   imhistmatchn   - Adjust N-D image to match its histogram to that of reference image.
%   imnoise        - Add noise to image.
%   imreducehaze   - Reduce atmospheric haze.
%   imsharpen      - Sharpen image using unsharp masking.
%   localcontrast  - Edge-aware local contrast manipulation of images.
%   locallapfilt   - Fast Local Laplacian Filtering of images.
%   medfilt2       - 2-D median filtering.
%   medfilt3       - 3-D median filtering.
%   ordfilt2       - 2-D order-statistic filtering.
%   stretchlim     - Find limits to contrast stretch an image.
%   intlut         - Convert integer values using lookup table.
%   wiener2        - 2-D adaptive noise-removal filtering.
%
% Linear filtering.
%   convmtx2           - 2-D convolution matrix.
%   fspecial           - Create predefined 2-D filters.
%   imboxfilt          - 2-D box filtering of images.
%   imboxfilt3         - 3-D box filtering of 3-D images.
%   imfilter           - N-D filtering of multidimensional images.
%   imgaborfilt        - 2-D Gabor filtering of images.
%   imgaussfilt        - 2-D Gaussian filtering of images.
%   imgaussfilt3       - 3-D Gaussian filtering of 3-D images.
%   integralBoxFilter  - 2-D integral box filtering of integral images.
%   integralBoxFilter3 - 3-D integral box filtering of 3-D integral images.
%   integralImage      - Compute upright or rotated integral image.
%   integralImage3     - Compute upright 3-D integral image.
%
% Linear 2-D filter design.
%   freqspace      - Determine 2-D frequency response spacing (MATLAB Toolbox).
%   freqz2         - 2-D frequency response.
%   fsamp2         - 2-D FIR filter using frequency sampling.
%   ftrans2        - 2-D FIR filter using frequency transformation.
%   fwind1         - 2-D FIR filter using 1-D window method.
%   fwind2         - 2-D FIR filter using 2-D window method.
%   gabor          - 2-D Gabor filter bank.
%
% Image deblurring.
%   deconvblind    - Deblur image using blind deconvolution.
%   deconvlucy     - Deblur image using Lucy-Richardson method.
%   deconvreg      - Deblur image using regularized filter.
%   deconvwnr      - Deblur image using Wiener filter.
%   edgetaper      - Taper edges using point-spread function.
%   otf2psf        - Convert optical transfer function to point-spread function.
%   psf2otf        - Convert point-spread function to optical transfer function.
%
% Image segmentation.
%   activecontour  - Segment image into foreground and background using active contour.
%   adaptthresh    - Adaptive image threshold using local first-order statistics.
%   bfscore        - Contour matching score for image segmentation.
%   boundarymask   - Find region boundaries of segmentation.
%   dice           - Sorensen-Dice similarity coefficient for image segmentation.
%   grabcut        - Segment image into foreground and background using iterative graph-based segmentation.
%   gradientweight - Calculate weights for image pixels based on image gradient.
%   grayconnected  - Select contiguous image region with similar gray values.
%   graydiffweight - Calculate weights for image pixels based on grayscale intensity difference.
%   graythresh     - Global image threshold using Otsu's method.
%   imbinarize     - Binarize image by thresholding.
%   imsegfmm       - Binary image segmentation using Fast Marching Method.
%   imseggeodesic  - Segment image into two or three regions using geodesic distance-based color segmentation.
%   jaccard        - Jaccard similarity coefficient for image segmentation.
%   lazysnapping   - Segment image into foreground and background using graph-based segmentation.
%   multithresh    - Multi-level image thresholding using Otsu's method.
%   otsuthresh     - Global histogram threshold using Otsu's method.
%   superpixels    - 2-D superpixel over-segmentation of images.
%   superpixels3   - 3-D superpixel over-segmentation of 3-D images.
%
% Image transforms.
%   dct2           - 2-D discrete cosine transform.
%   dctmtx         - Discrete cosine transform matrix.
%   fan2para       - Convert fan-beam projections to parallel-beam.
%   fanbeam        - Fan-beam transform.
%   fft2           - 2-D fast Fourier transform (MATLAB Toolbox).
%   fftn           - N-D fast Fourier transform (MATLAB Toolbox).
%   fftshift       - Reverse quadrants of output of FFT (MATLAB Toolbox).
%   idct2          - 2-D inverse discrete cosine transform.
%   ifft2          - 2-D inverse fast Fourier transform (MATLAB Toolbox).
%   ifftn          - N-D inverse fast Fourier transform (MATLAB Toolbox).
%   ifanbeam       - Inverse fan-beam transform.
%   iradon         - Inverse Radon transform.
%   para2fan       - Convert parallel-beam projections to fan-beam.
%   phantom        - Create head phantom image.
%   radon          - Radon transform.
%
% Neighborhood and block processing.
%   bestblk        - Block size with minimum padding.
%   blockproc      - Distinct block processing for image.
%   col2im         - Rearrange matrix columns into blocks.
%   colfilt        - Columnwise neighborhood operations.
%   im2col         - Rearrange image blocks into columns.
%   nlfilter       - General sliding-neighborhood operations.
%
% Morphological operations (intensity and binary images).
%   conndef        - Default connectivity array.
%   graydist       - Grey weighted distance transform.
%   imbothat       - Bottom-hat filtering.
%   imclearborder  - Suppress light structures connected to image border.
%   imclose        - Morphologically close image.
%   imdilate       - Dilate image.
%   imerode        - Erode image.
%   imextendedmax  - Extended-maxima transform.
%   imextendedmin  - Extended-minima transform.
%   imfill         - Fill image regions and holes.
%   imhmax         - H-maxima transform.
%   imhmin         - H-minima transform.
%   imimposemin    - Impose minima.
%   imopen         - Morphologically open image.
%   imreconstruct  - Morphological reconstruction.
%   imregionalmax  - Regional maxima.
%   imregionalmin  - Regional minima.
%   imtophat       - Top-hat filtering.
%   watershed      - Watershed transform.
%
% Morphological operations (binary images).
%   bwlookup       - Neighborhood operations using lookup tables.
%   bwarea         - Area of objects in binary image.
%   bwareaopen     - Remove small objects from binary image.
%   bwconncomp     - Find connected components in binary image.
%   bwdist         - Distance transform of binary image.
%   bwdistgeodesic - Geodesic distance transform of binary image.
%   bweuler        - Euler number of binary image.
%   bwhitmiss      - Binary hit-miss operation.
%   bwlabel        - Label connected components in 2-D binary image.
%   bwlabeln       - Label connected components in binary image.
%   bwmorph        - Morphological operations on binary image.
%   bwmorph3       - Morphological operations on 3D binary volume.
%   bwpack         - Pack binary image.
%   bwperim        - Find perimeter of objects in binary image.
%   bwselect       - Select objects in binary image.
%   bwselect3      - Select objects in 3-D binary image.
%   bwulterode     - Ultimate erosion.
%   bwunpack       - Unpack binary image.
%   labelmatrix    - Create label matrix from BWCONNCOMP structure.
%   makelut        - Create lookup table for use with APPLYLUT.
%
% Structuring element (STREL) creation and manipulation.
%   offsetstrel      - Create nonflat morphological structuring element (OFFSETSTREL).
%   reflect          - Reflect STREL and OFFSETSTREL about its center.
%   strel            - Create morphological structuring element (STREL).
%   decompose        - Return the decomposition elements of STREL and OFFSETSTREL.
%   isflat           - True for STRELs, false for OFFSETSTRELs.
%   strel/translate  - Translate STREL and OFFSETSTREL.
%
% Texture analysis.
%   entropy        - Entropy of intensity image.
%   entropyfilt    - Local entropy of intensity image.
%   graycomatrix   - Create gray-level co-occurrence matrix.
%   graycoprops    - Properties of gray-level co-occurrence matrix.
%   rangefilt      - Local range of image.
%   stdfilt        - Local standard deviation of image.
%
% Region-based processing.
%   poly2mask      - Convert region-of-interest polygon to mask.
%   regionfill     - Fill a region in an image.
%   roicolor       - Select region of interest based on color.
%   roifilt2       - Filter region of interest.
%   roipoly        - Select polygonal region of interest.
%
% Colormap manipulation.
%   brighten       - Brighten or darken colormap (MATLAB Toolbox).
%   cmpermute      - Rearrange colors in colormap (MATLAB Toolbox).
%   cmunique       - Eliminate unneeded colors in colormap of indexed image (MATLAB toolbox).
%   colormap       - Set or get color lookup table (MATLAB Toolbox).
%   imapprox       - Approximate indexed image by one with fewer colors (MATLAB toolbox).
%   rgbplot        - Plot RGB colormap components (MATLAB Toolbox).
%
% Color space conversions.
%   applycform     - Apply device-independent color space transformation.
%   hsv2rgb        - Convert HSV color values to RGB color space (MATLAB Toolbox).
%   iccfind        - Search for ICC profiles by description.
%   iccread        - Read ICC color profile.
%   iccroot        - Find system ICC profile repository.
%   iccwrite       - Write ICC color profile.
%   isicc          - True for complete profile structure
%   lab2double     - Convert L*a*b* color values to double.
%   lab2uint16     - Convert L*a*b* color values to uint16.
%   lab2uint8      - Convert L*a*b* color values to uint8.
%   makecform      - Create device-independent color space transformation structure (CFORM).
%   ntsc2rgb       - Convert NTSC color values to RGB color space.
%   rgb2hsv        - Convert RGB color values to HSV color space (MATLAB Toolbox).
%   rgb2ntsc       - Convert RGB color values to NTSC color space.
%   rgb2ycbcr      - Convert RGB color values to YCbCr color space.
%   whitepoint     - XYZ color values of standard illuminants.
%   xyz2double     - Convert XYZ color values to double.
%   xyz2uint16     - Convert XYZ color values to uint16.
%   ycbcr2rgb      - Convert YCbCr color values to RGB color space.
%
% ICC color profiles.
%   lab8.icm       - 8-bit Lab profile.
%   monitor.icm    - Typical monitor profile.
%                    Sequel Imaging, Inc., used with permission.
%   sRGB.icm       - sRGB profile.
%                    Hewlett-Packard, used with permission.
%   swopcmyk.icm   - CMYK input profile.
%                    Eastman Kodak, used with permission.
%
% Automatic white balance.
%   chromadapt    - Adjust the color balance of RGB images with chromatic adaptation.
%   colorangle    - Angle between two RGB vectors.
%   illumgray     - Illuminant estimation using the Gray World method.
%   illumpca      - Illuminant estimation using PCA on bright and dark pixels.
%   illumwhite    - Illuminant estimation using the White Patch Retinex method.
%   lin2rgb       - Apply gamma correction to linear RGB values.
%   rgb2lin       - Linearize gamma-corrected sRGB or Adobe RGB (1998) values.
%
% Array operations.
%   circshift      - Shift array circularly (MATLAB Toolbox).
%   padarray       - Pad array.
%
% Image types and type conversions.
%   demosaic       - Convert Bayer pattern encoded image to a truecolor image.
%   dither         - Convert image using dithering (MATLAB toolbox).
%   gray2ind       - Convert intensity image to indexed image.
%   grayslice      - Create indexed image from intensity image by thresholding.
%   im2bw          - Convert image to binary image by thresholding.
%   im2double      - Convert image to double precision.
%   im2int16       - Convert image to 16-bit signed integers.
%   im2java        - Convert image to Java image (MATLAB Toolbox).
%   im2java2d      - Convert image to Java BufferedImage.
%   im2single      - Convert image to single precision.
%   im2uint8       - Convert image to 8-bit unsigned integers.
%   im2uint16      - Convert image to 16-bit unsigned integers.
%   imquantize     - Quantize image using specified quantization levels and output values.
%   ind2gray       - Convert indexed image to intensity image.
%   ind2rgb        - Convert indexed image to RGB image (MATLAB Toolbox).
%   label2rgb      - Convert label matrix to RGB image.
%   label2idx      - Convert label matrix to cell array of linear indices.
%   mat2gray       - Convert matrix to intensity image.
%   rgb2gray       - Convert RGB image or colormap to grayscale.
%   rgb2ind        - Convert RGB image to indexed image (MATLAB Toolbox).
%
% High Dynamic Range Images.
%   blendexposure  - Create well-exposed image from images with different exposures.
%   hdrread        - Read Radiance HDR image.
%   hdrwrite       - Write Radiance HDR image.
%   localtonemap   - Render HDR image for viewing while enhancing local contrast.
%   makehdr        - Create high dynamic range image.
%   tonemap        - Render high dynamic range image for viewing.
%
% 3D Image Processing.
%   activecontour       - Segment volume into foreground and background using active contour.
%   adaptthresh         - Adaptive volume threshold using local first-order statistics.
%   affine3d            - Create 3-D affine transformation.
%   bwareaopen          - Remove small objects from binary volume.
%   bwconncomp          - Find connected components in binary volume.
%   bwselect3           - Select objects in binary volume.
%   dicomread           - Read DICOM volume.
%   edge3               - Find edges in intensity volume.
%   gradientweight      - Calculate weights for volumes based on gradient.
%   graydiffweight      - Calculate weights for volumes based on grayscale intensity difference.
%   histeq              - Enhance contrast using histogram equalization.
%   imabsdiff           - Absolute difference of two volumes.
%   imadd               - Add two volumes or add constant to volume.
%   imadjustn           - Adjust volume intensity values or colormap.
%   imbinarize          - Binarize volume by thresholding.
%   imbothat            - Bot-hat filtering for volumes.
%   imboxfilt3          - Box filtering of volumes.
%   imclose             - Morphologically close volume.
%   imdiffusefilt       - Anisotropic diffusion filtering of volumes.
%   imdilate            - Dilate volume.
%   imdivide            - Divide two volumes or divide volume by constant.
%   imerode             - Erode volume.
%   imfilter            - Filtering of volumes.
%   imgaussfilt3        - Gaussian filtering of volumes.
%   imgradient3         - Find the 3-D gradient magnitude and direction of a volume.
%   imgradientxyz       - Find the directional gradients of a volume.
%   imhist              - Display histogram of volumes.
%   imhistmatchn        - Adjust volume to match its histogram to that of a reference volume.
%   immultiply          - Multiply two volumes or multiply volume by constant.
%   imopen              - Morphologically open volume.
%   imreconstruct       - Morphological reconstruction for volumes.
%   imregionalmax       - Regional maxima for volumes.
%   imregionalmin       - Regional minima for volumes.
%   imregister          - Spatially register two volumes using intensity metric optimization.
%   imregdemons         - Estimate displacement field that aligns two volumes.
%   imresize3           - Resize volume.
%   imrotate3           - Rotate volume.
%   imsubtract          - Subtract two volumes or subtract constant from volume.
%   imwarp              - Apply geometric transformation to volume.
%   imsegfmm            - Binary volume segmentation using Fast Marching Method.
%   imtophat            - Top-hat filtering for volumes.
%   integralBoxFilter3  - Integral box filtering of integral volumes.
%   integralImage3      - Compute upright integral volumes.
%   medfilt3            - 3-D median filtering.
%   offsetstrel         - Create 3-D nonflat morphological structuring element (OFFSETSTREL).
%   regionprops         - Measure (some) properties of volumes.
%   superpixels3        - 3-D superpixel over-segmentation of volumes.
%   strel               - Create 3-D morphological structuring element (STREL).
%   watershed           - Watershed transform for volumes.
%
% Toolbox preferences.
%   iptgetpref     - Get value of Image Processing Toolbox preference.
%   iptprefs       - Display Image Processing Toolbox preferences dialog.
%   iptsetpref     - Set value of Image Processing Toolbox preference.
%
% Toolbox utility functions.
%   getrangefromclass - Get dynamic range of image based on its class.
%   iptcheckconn      - Check validity of connectivity argument.
%   iptcheckinput     - Check validity of array.
%   iptcheckmap       - Check validity of colormap.
%   iptchecknargin    - Check number of input arguments.
%   iptcheckstrs      - Check validity of text string.
%   iptnum2ordinal    - Convert positive integer to ordinal string.
%
% Modular interactive tools.
%   imageinfo           - Image Information tool.
%   imcolormaptool      - Choose Colormap tool.
%   imcontrast          - Adjust Contrast tool.
%   imdisplayrange      - Display Range tool.
%   imdistline          - Draggable Distance tool.
%   imgetfile           - Open Image dialog box.
%   impixelinfo         - Pixel Information tool.
%   impixelinfoval      - Pixel Information tool without text label.
%   impixelregion       - Pixel Region tool.
%   impixelregionpanel  - Pixel Region tool panel.
%   imputfile           - Save Image dialog box.
%   imsave              - Save Image tool.
%
% Navigational tools for image scroll panel.
%   imscrollpanel       - Scroll panel for interactive image navigation.
%   immagbox            - Magnification box for scroll panel.
%   imoverview          - Overview tool for image displayed in scroll panel.
%   imoverviewpanel     - Overview tool panel for image displayed in scroll panel.
%
% Utility functions for interactive tools.
%   axes2pix                  - Convert axes coordinate to pixel coordinate.
%   getimage                  - Get image data from axes.
%   getimagemodel             - Get image model object from image object.
%   imagemodel                - Image model object.
%   imattributes              - Information about image attributes.
%   imhandles                 - Get all image handles.
%   imgca                     - Get handle to current axes containing image.
%   imgcf                     - Get handle to current figure containing image.
%   imellipse                 - Create draggable, resizable ellipse.
%   imfreehand                - Create draggable freehand region.
%   imline                    - Create draggable, resizable line.
%   impoint                   - Create draggable point.
%   impoly                    - Create draggable, resizable polygon.
%   imrect                    - Create draggable, resizable rectangle.
%   iptaddcallback            - Add function handle to callback list.
%   iptcheckhandle            - Check validity of handle.
%   iptgetapi                 - Get Application Programmer Interface (API) for handle.
%   iptGetPointerBehavior     - Retrieve pointer behavior from HG object.
%   ipticondir                - Directories containing IPT and MATLAB icons.
%   iptPointerManager         - Install mouse pointer manager in figure.
%   iptremovecallback         - Delete function handle from callback list.
%   iptSetPointerBehavior     - Store pointer behavior in HG object.
%   iptwindowalign            - Align figure windows.
%   makeConstrainToRectFcn    - Create rectangularly bounded position constraint function.
%   truesize                  - Adjust display size of image.
%
% Interactive mouse utility functions.
%   getline        - Select polyline with mouse.
%   getpts         - Select points with mouse.
%   getrect        - Select rectangle with mouse.
%
% Demos.
%   iptdemos       - Index of Image Processing Toolbox demos.
%
% See also COLORSPACES, IMAGESLIB, IMDEMOS, IMUITOOLS, IPTFORMATS, IPTUTILS.

% Undocumented functions.
%   cmgamdef       - Default gamma correction table.
%   cmgamma        - Gamma correct colormap.
%   iptgate        - Gateway routine to call private functions.
%   imuitoolsgate  - Gateway routine to call private functions.

% Undocumented classes.
%   iptui.cpselectPoint   - Subclass of impoint used by cpselect.
%   iptui.imcropRect      - Subclass of imrect used by imcrop.
%   iptui.impolyVertex    - Subclass of impoint used by impoly.
%   iptui.pixelRegionRect - Subclass of imrect used by impixelregion.

% Discouraged functions.
%   applylut       - Neighborhood operations using lookup tables.
%   corner         - Find corners in intensity image.
%   cornermetric   - Create corner metric matrix from image.
%   roifill        - Fill in specified polygon in grayscale image.
%   subimage       - Display multiple images in single figure.

%   Copyright 1993-2017 The MathWorks, Inc.
