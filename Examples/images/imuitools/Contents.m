% Image Processing Toolbox --- imuitools
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
% Image display and exploration.
%   colorcloud          - Display 3D color gamut in specified color space.
%   immovie             - Make movie from multiframe image.
%   implay              - Play movies, videos, or image sequences.
%   imshow              - Display image in Handle Graphics figure.
%   imshowpair          - Compare differences between images.
%   imtool              - Display image in the Image Tool.
%   montage             - Display multiple image frames as rectangular montage.
%   warp                - Display image as texture-mapped surface.
%
% Image registration.
%   cpselect            - Control Point Selection Tool. 
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
%   ipticondir                - Directories containing IPT and MATLAB icons.
%   iptremovecallback         - Delete function handle from callback list.
%   iptwindowalign            - Align figure windows.
%   makeConstrainToRectFcn    - Create rectangularly bounded position constraint function.
%   truesize                  - Adjust display size of image.
%
% See also COLORSPACES, IMAGES, IMAGESLIB, IMDEMOS, IPTFORMATS, IPTUTILS.

%   Copyright 2004-2016 The MathWorks, Inc.  

% Undocumented classes
%   iptui.cpselectPoint   - Subclass of impoint used by cpselect.
%   iptui.imcropRect      - Subclass of imrect used by imcrop.
%   iptui.impolyVertex    - Subclass of impoint used by impoly.
%   iptui.pixelRegionRect - Subclass of imrect used by impixelregion. 

% Discouraged functions
%   subimage            - Display multiple images in single figure.
