%IMAGEMODEL Access to properties of an image relevant to its display.
%   IMGMODEL = IMAGEMODEL(HIMAGE) creates an image model object 
%   associated with the target image HIMAGE. HIMAGE is a handle 
%   to an image object or an array of handles to image objects. 
%   
%   IMAGEMODEL returns an image model object or, if HIMAGE is an 
%   array of image objects, an array of image model objects. 
%  
%   An image model object stores information about an image
%   such as class, type, display range, width, height, minimum
%   intensity value and maximum intensity value.  
%   
%   The image model object supports methods that you can use
%   to access this information, get information about the pixels
%   in an image, and perform special text formatting.  
%   The following lists these methods with a brief description. 
%   Use METHODS(IMGMODEL) to get a list of image model methods. 
%
%   getClassType
%
%       Returns a string indicating the class of the image.
%
%           str = getClassType(IMGMODEL)
%
%       where IMGMODEL is a valid image model and STR is a text
%       string, such as 'uint8'.
%
%   getDisplayRange
%
%       Returns a double array containing the minimum and 
%       maximum values of the display range for an intensity image.
%       For image types other than intensity, the value returned 
%       is an empty array.
%   
%           disp_range = getDisplayRange(IMGMODEL)
%
%       where IMGMODEL is a valid image model and disp_range is 
%       an array of doubles such as [0 255]. 
%
%   getImageHeight
%
%       Returns a double scalar containing the number of rows.
%
%          HEIGHT = getImageHeight(IMGMODEL)
%
%       where IMGMODEL is a valid image model and HEIGHT is 
%       a double scalar.    
%
%
%   getImageType
%
%       Returns a text string indicating the image type. 
%
%          STR = getImageType(IMGMODEL)
%
%       where IMGMODEL is a valid image model and STR is 
%       one of the text strings 'intensity', 'truecolor',
%       'binary', or 'indexed'.
%
%   getImageWidth
%
%       Returns a double scalar containing the number of columns.
%
%          WIDTH = getImageWidth(IMGMODEL)
%
%       where IMGMODEL is a valid image model and WIDTH is 
%       a double scalar.
%
%   getMinIntensity
%
%       Returns the minimum value in the image calculated as 
%       min(Image(:)). For an intensity image, the value returned is 
%       the minimum intensity. For an indexed image, the value 
%       returned is the minimum index. For any other image type, the 
%       value returned is an empty array.
%       
%          MINVAL = getMinIntensity(IMGMODEL)
%
%       where IMGMODEL is a valid image model and MINVAL is 
%       a numeric value. The class of MINVAL depends on the class
%       of the target image. 
%
%   getMaxIntensity
%
%       Returns the maximum value in the image calculated as 
%       max(Image(:)). For an intensity image, the value returned is 
%       the maximum intensity. For an indexed image, the value 
%       returned is the maximum index. For any other image type, the 
%       value returned is an empty array.
%       
%          MAXVAL = getMaxIntensity(IMGMODEL)
%
%       where IMGMODEL is a valid image model and MAXVAL is 
%       a numeric value. The class of MAXVAL depends on the class
%       of the target image.
%
%
%   The image model object also supports methods that return image 
%   information as a text string or perform specialized formatting 
%   of information. 
%  
%   getPixelInfoString
%   
%       Returns a text string containing value of the pixel at the 
%       location specified by ROW and COLUMN.
%   
%           STR = getPixelInfoString(IMGMODEL,ROW,COLUMN)
%
%       where IMGMODEL is a valid image model and ROW and COLUMN are 
%       numeric scalar values. STR is a character array. For example,
%       for an RGB image, the method returns a text string such as 
%       '[66 35 60]'.
%  
%   getDefaultPixelInfoString
%
%       Returns a text string indicating the type of information returned
%       in a pixel information string. This string can be used in place
%       of actual pixel information values.
%
%           STR = getDefaultPixelInfoString(IMGMODEL)
%
%       where IMGMODEL is a valid image model. Depending on the image type,
%       STR can be the text string 'Intensity','[R G B]','BW', or 
%       '<Index> [R G B]'.  
%
%   getDefaultPixelRegionString
%
%       Returns a text string indicating the type of information displayed
%       in the Pixel Region tool for each image type. This string can be
%       used in place of actual pixel values.
%
%           STR = getDefaultPixelRegionString(IMGMODEL)
%
%       where IMGMODEL is a valid image model. Depending on the image type,
%       STR can be the text string '000','R:000 G:000 B:000]','0', or 
%       '<000> R:0.00 G:0.00 B:0.00'.  
%
%   getPixelValue
%
%       Returns the value of the pixel at the location specified
%       by ROW and COLUMN as a numeric array.
%
%           VAL = getPixelValue(IMGMODEL,ROW,COLUMN)
%
%       where IMGMODEL is a valid image model and ROW and COLUMN are 
%       numeric scalar values. The class of VAL depends on the class 
%       of the target image. 
%
%   getScreenPixelRGBValue
%
%       Returns the screen display value of the pixel at the location 
%       specified by ROW and COLUMN as a double array.
%
%           VAL = getScreenPixelRGBValue(IMGMODEL,ROW,COLUMN)
%
%       where IMGMODEL is a valid image model and ROW and COLUMN are 
%       numeric scalar values. VAL is an array of doubles, such as
%       [0.2 0.5 0.3].
%
%
%   In addition to these information formatting functions, the image
%   model supports methods that return handles to functions that
%   perform special formatting.
%
%   getNumberFormatFcn
%
%       Returns the handle to a function that converts a 
%       numeric value into a string.
%
%           FUN = getNumberFormatFcn(IMGMODEL)
%
%       where IMGMODEL is a valid image model. FUN is a handle
%       to a function that accepts a numeric value and returns 
%       the value as a text string. For example, you can use
%       this function to convert the numeric return value of
%       the getPixelValue method into a text string.
%
%           STR = FUN(getPixelValue(IMGMODEL,100,100)) 
%
%   getPixelRegionFormatFcn
%
%       Returns a handle to a function that formats the value
%       of a pixel into a text string. 
%   
%           FUN = getPixelRegionFormatFcn(IMGMODEL)
%
%       where IMGMODEL is a valid image model. FUN is a handle
%       to a function that accepts the location (ROW,COLUMN) of
%       a pixel in the target image and returns the value of
%       the pixel as a specially formatted text string. For 
%       example, when used with an RGB image, this function
%       returns a text string of the form 'R:000 G:000 B:000'
%       where 000 is the actual pixel value.
%
%           STR = FUN(100,100)
%
%   Methods
%   -------
%   Type "methods imagemodel" to see a list of the methods.
%
%   For more information about a particular method, type
%   "help imagemodel/methodname" at the command line.
%
%   Note
%   ----  
%   IMAGEMODEL works by querying the image object's CData.
%
%   Examples
%   --------
%
%       h = imshow('peppers.png');
%       im = imagemodel(h);
%
%       figure,subplot(1,2,1)
%       h1 = imshow('hestain.png');
%       subplot(1,2,2)
%       h2 = imshow('coins.png');
%       im = imagemodel([h1 h2]);
%   
%   See also GETIMAGEMODEL.

%   Copyright 1993-2016 The MathWorks, Inc.

classdef imagemodel < handle
    
    properties  (Access = 'private')
        
        % Handle to image object
        ImageHandle
        
        % function that takes one band value of a color in the colormap as
        % an input and returns a formatted string.
        MapEntryFormatFcn
        
        % original image datatype if it is not supported by the HG image
        % object CData property
        ImageOrigClassType
        
    end % private properties
    
    
    methods (Access = 'public')
        
        %---------------------------------------
        function obj = imagemodel(varargin)
            %imagemodel  Constructor for imagemodel.
            
            hImage = parseInputs(varargin{:});
            
            if ~isempty(hImage)
                numHandles = numel(hImage);
                obj = imagemodel.newarray(1,numHandles);
                
                for k = 1 : numHandles
                    obj(k).ImageHandle = hImage(k);
                    obj(k).MapEntryFormatFcn = @dispMapEntryFcn;
                end
            end
            
        end % constructor
        
        
        %----------------------
        function disp(imgmodel)
            %disp Display method for imagemodel objects.
            %
            %   disp(imgmodel) prints a description of the imagemodel
            %   imgmodel to the command window.
            
            if length(imgmodel) > 1
                s = size(imgmodel);
                str = sprintf('%dx',s);
                str(end)=[];
                str = getString(message('images:imagemodel:arrayOfObjects',str));
                fprintf('%s\n',str);
                
            else
                
                features = {
                    'ClassType',    getClassType(imgmodel);
                    'DisplayRange', getDisplayRange(imgmodel);
                    'ImageHeight',  getImageHeight(imgmodel);
                    'ImageType',    getImageType(imgmodel);
                    'ImageWidth',   getImageWidth(imgmodel);
                    'MinIntensity', getMinIntensity(imgmodel);
                    'MaxIntensity', getMaxIntensity(imgmodel);
                    };
                
                if strcmp(getImageType(imgmodel),'indexed')
                    features{6,1} = 'MinIndex';
                    features{7,1} = 'MaxIndex';
                end
                
                fprintf('%s\n\n',getString(message(...
                    'images:imagemodel:objectAccessingImageWithTheseProperties')));
                disp(cell2struct(features(:,2),features(:,1),1))
            end
            
        end % disp
        
        
        %-------------------------
        function display(imgmodel) %#ok<DISPLAY>
            %display Display method for imagemodel objects.
            %   display(imgmodel) prints the input variable name
            %   associated with imgmodel (if any) to the command window
            %   and then calls disp(imgmodel).
            %   display(imgmodel) also prints additional blank lines if the
            %   FormatSpacing property is 'loose'.
            
            if isequal(get(0,'FormatSpacing'),'compact')
                disp([inputname(1) ' =']);
                disp(imgmodel)
            else
                disp(' ')
                disp([inputname(1) ' =']);
                disp(' ');
                disp(imgmodel)
                disp(' ');
            end
            
        end % display
        
        
        %-------------------------------------------
        function imageclass = getClassType(imgmodel)
            %getClassType Class of image associated with the imagemodel.
            %   IMAGECLASS = getClassType(IMGMODEL) returns the class
            %   associated with the imagemodel IMGMODEL.  IMAGECLASS is a
            %   string specifying the class of the image object's CData.
            %   IMGMODEL is expected to contain only one imagemodel object.
            %
            %   Example
            %   -------
            %       h = imshow('moon.tif');
            %       im = imagemodel(h);
            %       imageClass = getClassType(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            
            if isempty(imgmodel.ImageOrigClassType)
                imageclass = class(get(imgmodel.ImageHandle,'CData'));
            else
                imageclass = imgmodel.ImageOrigClassType;
            end
            
        end % getClassType
        
        
        %----------------------------------------------------
        function string = getDefaultPixelInfoString(imgmodel)
            %getDefaultPixelInfoString Default string used in pixel information tool.
            %   STRING = getDefaultPixelInfoString(IMGMODEL) returns the default string
            %   used in IMPIXELINFOVAL.
            %
            %   IMGMODEL is expected to contain one image model object.
            %
            %   Example
            %   -------
            %       h = imshow('shadow.tif');
            %       im = imagemodel(h);
            %       string = getDefaultPixelInfoString(im);
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            string = getDataFromImageTypeFormatter(imgmodel,'DefaultPixelInfoString');
            
        end % getDefaultPixelInfoString
        
        
        %------------------------------------------------------
        function string = getDefaultPixelRegionString(imgmodel)
            %getDefaultPixelRegionString Default string used in pixel region panel.
            %   STRING = getDefaultPixelRegionString(IMGMODEL) returns the default string
            %   used in IMPIXELREGIONPANEL.
            %
            %   IMGMODEL is expected to contain one image model object.
            %
            %   Example
            %   -------
            %       h = imshow('shadow.tif');
            %       im = imagemodel(h);
            %       string = getDefaultPixelRegionString(im);
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            string = getDataFromImageTypeFormatter(imgmodel,'DefaultPixelRegionString');
            
        end % getDefaultPixelRegionString
        
        
        %-----------------------------------------
        function range = getDisplayRange(imgmodel)
            %getDisplayRange Display range of image associated with imagemodel.
            %   RANGE = getDisplayRange(IMGMODEL) returns the display range of the
            %   image object associated with the imagemodel.  The display range is
            %   empty if image object does not contain an intensity image.
            %
            %   Example
            %   -------
            %       I = imread('pout.tif');
            %       h = imshow(I,[])
            %       im = imagemodel(h);
            %       displayrange = getDisplayRange(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            
            if strcmp(findImageType(imgmodel.ImageHandle),'intensity')
                range = get(ancestor(imgmodel.ImageHandle,'Axes'),'Clim');
            else
                range = [];
            end
            
        end % getDisplayRange
        
        
        %-----------------------------------------
        function height = getImageHeight(imgmodel)
            %getImageHeight Image height associated with the imagemodel.
            %   HEIGHT = getImageHeight(IMGMODEL) returns the image height associated with the
            %   imagemodel IMGMODEL.  IMGMODEL is expected to contain only one imagemodel
            %   object.
            %
            %   Example
            %   -------
            %       h = imshow('moon.tif');
            %       im = imagemodel(h);
            %       imageHeight = getImageHeight(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            height = size(get(imgmodel.ImageHandle,'CData'),1);
            
        end % getImageHeight
        
        
        %------------------------------------------
        function imagetype = getImageType(imgmodel)
            %getImageType Image type associated with the imagemodel IMGMODEL.
            %   IMAGETYPE = getImageType(IMGMODEL) returns the image type associated with
            %   the imagemodel IMGMODEL. IMAGETYPE can be 'intensity', 'truecolor',
            %   'binary', or 'indexed'. IMGMODEL is expected to contain one imagemodel
            %   object.
            %
            %   Example
            %   -------
            %       [X,map] = imread('trees.tif');
            %       h = imshow(X,map);
            %       im = imagemodel(h);
            %       imageType = getImageType(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            imagetype = findImageType(imgmodel.ImageHandle);
            
        end % getImageType
        
        
        %---------------------------------------
        function width = getImageWidth(imgmodel)
            %getImageWidth Image width associated with the imagemodel.
            %   WIDTH = getImageWidth(IMGMODEL) returns the image width associated with the
            %   imagemodel IMGMODEL.  IMGMODEL is expected to contain only one imagemodel
            %   object.
            %
            %   Example
            %   -------
            %       h = imshow('moon.tif');
            %       im = imagemodel(h);
            %       imageWidth = getImageWidth(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            width    = size(get(imgmodel.ImageHandle,'CData'),2);
            
        end % getImageWidth
        
        
        %-----------------------------------------
        function value = getMaxIntensity(imgmodel)
            %getMaxIntensity Maximum intensity of image associated with the imagemodel.
            %   VALUE = getMaxintensity(IMGMODEL) returns the maximum intensity of the
            %   image associated with the imagemodel IMGMODEL.  For an intensity or
            %   indexed image, VALUE is the corresponding maximum value or index. For a
            %   binary or truecolor image, VALUE is [].
            %
            %   IMGMODEL is expected to contain only one imagemodel object.
            %
            %   Example
            %   -------
            %       h = imshow('moon.tif');
            %       im = imagemodel(h);
            %       maxIntensity = getMaxIntensity(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            imageType = findImageType(imgmodel.ImageHandle);
            
            if strcmp(imageType,'intensity') || strcmp(imageType,'indexed')
                img = get(imgmodel.ImageHandle,'CData');
                value = max(img(:));
            else
                value = [];
            end
            
        end % getMaxIntensity
        
        
        %-----------------------------------------
        function value = getMinIntensity(imgmodel)
            %getMinIntensity Minimum intensity of image associated with the imagemodel.
            %   VALUE = getMinintensity(IMGMODEL) returns the minimum intensity of the
            %   image associated with the imagemodel IMGMODEL.  For an intensity or
            %   indexed image, VALUE is the corresponding minimum value or index. For a
            %   binary or truecolor image, VALUE is [].
            %
            %   IMGMODEL is expected to contain only one imagemodel object.
            %
            %   Example
            %   -------
            %       h = imshow('moon.tif');
            %       im = imagemodel(h);
            %       minIntensity = getMinIntensity(im)
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            imageType = findImageType(imgmodel.ImageHandle);
            
            if strcmp(imageType,'intensity') || strcmp(imageType,'indexed')
                img = get(imgmodel.ImageHandle,'CData');
                value = min(img(:));
            else
                value = [];
            end
            
        end % getMinIntensity
        
        
        %------------------------------------------------------------------------------
        function [formatFcn,containsFloat,needsExponent] = getNumberFormatFcn(imgmodel)
            %getNumberFormatFcn Returns handle to function that returns formatted number string.
            %   formatFcn = getNumberFormatFcn(IMGMODEL) returns a function
            %   handle. formatFcn has this signature:
            %
            %       STR = formatFcn(V)
            %
            %   where STR is a formatted string representation of V, a scalar.
            %
            %   IMGMODEL is expected to contain one image model object.
            %
            %   Example
            %   -------
            %       This example shows how the formatted string depends on the
            %       image class type.
            %
            %       I = imread('snowflakes.png');
            %       h = imshow(I)
            %       im = imagemodel(h);
            %       formatFcn = getNumberFormatFcn(imgmodel)
            %       string = formatFcn(I(1,1))
            %
            %       I = im2single(I);
            %       h = imshow(I);
            %       im = imagemodel(h);
            %       formatFcn = getNumberFormatFcn(im)
            %       string = formatFcn(I(1,1))
            
            %   [formatFcn,containsFloat] = getNumberFormatFcn(imgmodel) returns
            %   a boolean containsFloat indicating whether IMGMODEL accesses
            %   an image containing floating point values. containsExponent
            %
            %   [formatFcn,containsFloat,needsExponent] = getNumberFormatFcn(imgmodel)
            %   returns a boolean needsExponent indicating whether the function uses
            %   exponent notation to represent the image data.
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            imageClass = getClassType(imgmodel);
            
            containsFloat = false;
            
            switch imageClass
                case {'int64','uint64','int32','uint32','int16','uint16','uint8','int8','logical'}
                    needsExponent = false;
                    formatFcn = @(value) sprintf('%d',value);
                    
                case {'double','single'}
                    img = get(imgmodel.ImageHandle,'CData');
                    
                    absMaxVal = abs(max(img(:)));
                    
                    % The way we check if the image doesn't have floating pt numbers is
                    % not ideal, but it is faster than the old version. Plan to
                    % refactor this in the next release.
                    try
                        validateattributes(img,{'double', 'single'}, {'integer'}, ...
                            mfilename, 'img',1);
                    catch ME %#ok<NASGU>
                        % Because we are catching ME, lasterror will not be populated
                        % if validateattributes errors, which is what we want.
                        containsFloat = true;
                    end
                    
                    if containsFloat
                        needsExponent = absMaxVal >= 10^4 | absMaxVal < 10^-2;
                        if needsExponent
                            formatFcn = @createStringForExponents;
                        else
                            formatFcn = @(value) sprintf('%1.2f',value);
                        end
                    else
                        % we do not want int16 data to be viewed as an exponent
                        needsExponent = absMaxVal > 32768 ;
                        
                        if needsExponent
                            formatFcn = @createStringForExponents;
                        else
                            formatFcn = @(value) sprintf('%d',value);
                        end
                    end
                    
                otherwise
                    error(message('images:imagemodel:invalidClass'))
            end
            
        end % getNumberFormatFcn
        
        
        %-------------------------------------------------
        function string = getPixelInfoString(imgmodel,r,c)
            %getPixelInfoString Formatted pixel value string.
            %   STRING = getPixelInfoString(IMGMODEL,R,C) returns a formatted
            %   string containing the image pixel value at the location R,C.
            %
            %   IMGMODEL is expected to contain one image model object.
            %
            %   Example
            %   -------
            %       h = imshow('shadow.tif');
            %       im = imagemodel(h);
            %       string = getPixelInfoString(im,5,4);
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            getString = getDataFromImageTypeFormatter(imgmodel,'PixelInfoString');
            string = getString(r,c);
            
        end % getPixelInfoString
        
        
        %-----------------------------------------------------
        function formatFcn = getPixelRegionFormatFcn(imgmodel)
            %getPixelRegionString Returns a function handle to format pixel value
            %   formatFcn = getPixelRegionString(IMGMODEL) returns a function
            %   handle. formatFcn has this signature:
            %
            %       STR = formatFcn(R,C)
            %
            %   where STR is a formatted string containing the pixel value at the location
            %   row R and column C.
            %
            %   IMGMODEL is expected to contain one image model object.
            %
            %   Example
            %   -------
            %       h = imshow('shadow.tif');
            %       im = imagemodel(h);
            %       getPixelString = getPixelRegionFormatFcn(im);
            %       string = getPixelRegionString(5,4);
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            formatFcn = getDataFromImageTypeFormatter(imgmodel,'PixelRegionString');
            
        end % getPixelRegionFormatFcn
        
        
        %-------------------------------------------
        function value = getPixelValue(imgmodel,r,c)
            %getPixelValue Pixel value at a given location.
            %   VALUE = getPixelValue(IMGMODEL,R,C) returns a pixel value at the
            %   location row R, column C.
            %
            %   IMGMODEL is expected to contain one image model object.
            %
            %   Example
            %   -------
            %       h = imshow('shadow.tif');
            %       im = imagemodel(h);
            %       value = getPixelValue(im,5,4);
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            getValue = getDataFromImageTypeFormatter(imgmodel,'PixelValue');
            value = getValue(r,c);
            
        end % getPixelValue
        
        
        %-------------------------------------------------------
        function rgbValue = getScreenPixelRGBValue(imgmodel,r,c)
            %getScreenPixelRGBValue RGB value of a pixel displayed on the screen.
            %   RGBVALUE = getScreenPixelRGBValue(IMGMODEL,R,C) takes an imagemodel
            %   IMGMODEL, row R, and column C as inputs and returns the RGB value of the
            %   pixel at that location as displayed on the screen. IMGMODEL must contain
            %   one imagemodel object.
            %
            %   Example
            %   -------
            %       This example demonstrates how the display range of an image in a
            %       figure affects the RGB value of pixel when it is displayed on the
            %       screen.
            %
            %       I = imread('pout.tif');
            %       h = imshow(I);
            %       im = imagemodel(h);
            %       getScreenPixelRGBValue(im,1,1)
            %
            %       figure
            %       h2 = imshow(I,[]);
            %       im2 = imagemodel(h2);
            %       getScreenPixelRGBValue(im2,1,1)
            
            if numel(imgmodel) > 1
                error(message('images:imagemodel:invalidNumImageModels'))
            end
            
            h = imgmodel.ImageHandle;
            imageType = findImageType(h);
            img = get(h,'CData');
            
            if ~isempty(img)
                switch imageType
                    
                    case 'truecolor'
                        range = getrangefromclass(img);
                        pixelValue = double(getPixelValue(imgmodel,r,c));
                        rgbValue = (pixelValue - range(1)) ./ ...
                            (range(2) - range(1));
                        rgbValue = min(1, max(0, rgbValue));
                        
                    case 'indexed'
                        rgbValue = double(getPixelValue(imgmodel,r,c));
                        
                    otherwise
                        % intensity or binary image
                        map = colormap(ancestor(h,'Axes'));
                        numentry = size(map,1);
                        range = get(ancestor(h,'Axes'),'Clim');
                        
                        % range(1) maps to index #1 into the colormap and range(2) maps to index
                        % #numentry into the colormap.  The index into the colormap is scaled
                        % using these factors.
                        slope = (numentry - 1) / (range(2) - range(1));
                        intercept = 1 - (slope * range(1));
                        
                        M = size(img, 1);
                        
                        index = round(slope*double(img((c(:) - 1)*M + r(:))) + intercept);
                        index = min(numentry,max(1,index));
                        rgbValue = map(index,:);
                end
            else
                rgbValue = get(ancestor(h,'Figure'),'Color');
            end
        end % getScreenPixelRGBValue
        
        
        %------------------------------------------------------------
        function imgmodel = setImageOrigClassType(imgmodel,classType)
            %setImageOrigClassType set class of image in the imagemodel.
            %   setImageOrigClassType(IMGMODEL,classType) sets the class of the image
            %   associated with the imagemodel. This function is useful in GUIs that open
            %   images whose class is not supported by IMAGE, e.g., int16 and
            %   single. However, be careful when using this function as it does break the
            %   dynamic nature of the imagemodel object.
            
            imgmodel = checkForMultipleImageModels(imgmodel,mfilename);
            
            %check if this imagemodel is also stored in the image object's appdata.
            appdataImgmodel = getappdata(imgmodel.ImageHandle,'imagemodel');
            
            if isequal(imgmodel,appdataImgmodel)
                
                imgmodel.ImageOrigClassType = classType;
                setappdata(imgmodel.ImageHandle,'imagemodel',imgmodel);
                
            else
                imgmodel.ImageOrigClassType = classType;
            end
            
        end % setImageOrigClassType
        
    end % public methods
    
    
    methods (Access = 'private')
        
        %--------------------------------------------------------------
        function oneIM = checkForMultipleImageModels(imgmodel,filename)
            %checkForMultipleImageModels Check if input contains multiple imagemodels.
            %   IM = checkForMultipleImageModels(IMGMODEL, FILENAME) checks if the
            %   input IMGMODEL to the function FILENAME contains more than one
            %   imagemodel. IF IMGMODEL contains multiple imagemodel objects, then
            %   checkForMultipleImageModels returns the first element in IMGMODEL array
            %   and issues a warning.
            
            if numel(imgmodel) > 1
                warning(message('images:imagemodel:ignoreMultipleImageModels'))
            end
            
            oneIM = imgmodel(1);
            
        end % checkForMultipleImageModels
        
        
        %----------------------------------------------------------
        function data = getDataFromImageTypeFormatter(imgmodel,tag)
            %getDataFromImageTypeFormatter Data based on imgmodel.
            %   DATA = getDataFromImageTypeFormatter(IMGMODEL,TAG) returns DATA from the
            %   imagemodel as specified by TAG. TAG can have various options as listed
            %   in the first column of the table below. The DATA generated as a result
            %   of TAG is listed in the second column.
            %
            %   'DefaultPixelInfoString'      Default string used in IMPIXELINFOVAL.
            %
            %   'PixelInfoString'             Function handle that takes a row and
            %                                 column as an input and returns a formatted
            %                                 string containing the pixel value at that
            %                                 location.
            %
            %   'DefaultPixelRegionString'    Default string used in IMPIXELREGIONPANEL.
            %
            %   'PixelRegionString'           Function handle that takes a row and
            %                                 column as an input and returns a
            %                                 formatted string containing
            %                                 the pixel value at that location.
            %
            %   'PixelValue'                  Function handle that takes a row and
            %                                 column as an input and returns the pixel
            %                                 value at that location.
            
            [formatNumber, containsFloat] = getNumberFormatFcn(imgmodel);
            
            switch findImageType(imgmodel.ImageHandle)
                case 'intensity'
                    data = intensityformatter;
                    
                case 'truecolor'
                    data = truecolorformatter;
                    
                case 'binary'
                    data = binaryformatter;
                    
                case 'indexed'
                    data = indexedformatter;
                    
                otherwise
                    error(message('images:imagemodel:imageType'))
            end
            
            
            %---------------------------------
            function data = intensityformatter
                
                switch tag
                    case 'PixelInfoString'
                        data = @getIntensityPixelInfoString;
                    case 'DefaultPixelInfoString'
                        %data = 'Intensity';
                        data  = getString(message('images:commonUIString:Intensity'));
                    case 'PixelRegionString'
                        data = @getIntensityPixelRegionStrings;
                    case 'DefaultPixelRegionString'
                        data = getDefaultPixelRegNumString;
                    case 'PixelValue'
                        data = @getValues;
                end
                
            end % intensityFormatter
            
            
            %------------------------------
            function data = binaryformatter
                
                switch tag
                    case 'PixelInfoString'
                        data = @getIntensityPixelInfoString;
                    case 'DefaultPixelInfoString'
                        %data = 'BW';
			data = getString(message('images:commonUIString:BW'));
                    case 'PixelRegionString'
                        data = @getIntensityPixelRegionStrings;
                    case 'DefaultPixelRegionString'
                        data = '0';
                    case 'PixelValue'
                        data = @getValues;
                end
            end % binaryFormatter
            
            
            %---------------------------------
            function data = truecolorformatter
                
                switch tag
                    case 'PixelInfoString'
                        data = @getPixelInfoString;
                    case 'DefaultPixelInfoString'
                        %data = '[R G B]';
			data = getString(message('images:commonUIString:RGB'));
                    case 'PixelRegionString'
                        data = @getPixelRegionStrings;
                    case 'DefaultPixelRegionString'
                        data = getDefaultPixelRegionString;
                    case 'PixelValue'
                        data = @getRGBValues;
                end
                
                
                %-------------------------------------------------
                function pixelInfoString = getPixelInfoString(r,c)
                    
                    color = getRGBValues(r,c);
                    [redString,greenString,blueString] = ...
                        getRGBColorStrings(color,formatNumber);
                    pixelInfoString = sprintf('[%1s %1s %1s]', redString{1}, ...
                        greenString{1}, blueString{1});
                    
                end % getPixelInfoString
                
                
                %--------------------------------------------
                function string = getDefaultPixelRegionString
                    
                    color = getDefaultPixelRegNumString;
                    string = sprintf('R:%1s\nG:%1s\nB:%1s', color,color,color);
                    
                end % getDefaultPixelRegionString
                
                
                %-------------------------------------------------------
                function pixelRegionStrings = getPixelRegionStrings(r,c)
                    
                    colors = getRGBValues(r,c);
                    
                    [redStrings,greenStrings,blueStrings] = ...
                        getRGBColorStrings(colors,formatNumber);
                    
                    max_length = max([max(cellfun('prodofsize', redStrings)) ...
                        max(cellfun('prodofsize', greenStrings)) ...
                        max(cellfun('prodofsize', blueStrings))]);
                    
                    formatString = sprintf('R:%%%ds\nG:%%%ds\nB:%%%ds', ...
                        max_length, max_length, max_length);
                    
                    numCoord = numel(r);
                    pixelRegionStrings = cell(numCoord, 1);
                    
                    for k = 1:numCoord
                        pixelRegionStrings{k} = sprintf(formatString, redStrings{k}, ...
                            greenStrings{k}, ...
                            blueStrings{k});
                    end
                    
                end % getPixelRegionStrings
                
                
                %---------------------------------
                function color = getRGBValues(r,c)
                    
                    img = get(imgmodel.ImageHandle,'CData');
                    M = size(img, 1);
                    N = size(img, 2);
                    idx = (c-1)*M + r;
                    page_size = M*N;
                    if ~isempty(img)
                        color = [img(idx) img(idx + page_size) img(idx + 2*page_size)];
                    else
                        color = [];
                    end
                    
                end % getRGBValues
                
            end % end of truecolorFormatter
            
            
            %-------------------------------
            function data = indexedformatter
                
                % the case where the image is a floating pt image with a cdatamapping
                % of 'direct' is handled in the indexedformatter to preserve the
                % dynamic nature of the imagemodel object.
                switch tag
                    case 'PixelInfoString'
                        data = @getPixelInfoString;
                    case 'DefaultPixelInfoString'
                        if ~containsFloat			    
                            %data = '<Index>  [R G B]';
			    data = getString(message('images:commonUIString:indexRGB'));
                        else
                            %data = 'Value  <Index>  [R G B]';
			    data = getString(message('images:commonUIString:valueIndexRGB'));
                        end
                    case 'PixelRegionString'
                        data = @getPixelRegionStrings;
                    case 'DefaultPixelRegionString'
                        data = getDefaultPixelRegionString;
                    case 'PixelValue'
                        data = @getIndexColors;
                        
                end % indexedformatter
                
                
                %-------------------------------------------------
                function pixelInfoString = getPixelInfoString(r,c)
                    
                    [color,index,mapIndex] = getIndexColors(r,c);
                    
                    [redString,greenString,blueString] = getRGBColorStrings(color, ...
                        imgmodel.MapEntryFormatFcn);
                    pixelInfoString = sprintf('%1s  [%1s %1s %1s]', ...
                        getIndexString(index,mapIndex), ...
                        redString{1}, greenString{1}, ...
                        blueString{1});
                    
                end % getPixelInfoString
                
                
                %-------------------------------------------------------
                function pixelRegionStrings = getPixelRegionStrings(r,c)
                    
                    [colors,indices,mapIndices] = getIndexColors(r,c);
                    
                    [redStrings,greenStrings,blueStrings] = ...
                        getRGBColorStrings(colors,imgmodel.MapEntryFormatFcn);
                    
                    numCoord = numel(r);
                    pixelRegionStrings = cell(numCoord, 1);
                    
                    for k = 1:numCoord
                        if isempty(indices)
                            pixelRegionStrings{k} = sprintf('<%1s>\nR:%1s\nG:%1s\nB:%1s', ...
                                ' ', redStrings{k}, ...
                                greenStrings{k}, blueStrings{k});
                        else
                            pixelRegionStrings{k} = ...
                                sprintf('%1s\nR:%1s\nG:%1s\nB:%1s', ...
                                getIndexString(indices(k),mapIndices(k)), ...
                                redStrings{k}, greenStrings{k}, blueStrings{k});
                        end
                    end
                    
                end % getPixelRegionStrings
                
                
                %--------------------------------------------
                function string = getDefaultPixelRegionString
                    
                    formatMapEntry = imgmodel.MapEntryFormatFcn;
                    mapEntry = formatMapEntry(0);
                    
                    if ~containsFloat
                        indexString = getDefaultPixelRegNumString;
                        string = sprintf('<%s>\nR:%s\nG:%s\nB:%s', indexString,mapEntry, ...
                            mapEntry,mapEntry);
                    else
                        valueString = formatNumber(0);
                        indexString = '000';  %choosing some that is reasonable
                        %given this edge case
                        string = sprintf('%s <%s>\nR:%s\nG:%s\nB:%s',valueString, ...
                            indexString,mapEntry, mapEntry,mapEntry);
                    end
                    
                end % getDefaultPixelRegionString
                
                
                %----------------------------------------------------
                function [color,index,mapIndex] = getIndexColors(r,c)
                    
                    classType = getClassType(imgmodel);
                    map = colormap(ancestor(imgmodel.ImageHandle, 'axes'));
                    
                    index = getValues(r,c);
                    
                    if ~isempty(index)
                        if ~strcmp(classType,'double') && ~strcmp(classType,'single')
                            mapIndex = index + 1;
                        else
                            if ~containsFloat
                                mapIndex = max(1,index);
                            else
                                mapIndex = max(1,floor(index));
                            end
                        end
                        mapIndex = min(mapIndex,size(map,1));
                        color = map(mapIndex,:);
                    else
                        mapIndex = index;
                        color = [];
                    end
                    
                end % getIndexColors
                
                
                %-----------------------------------------------
                function string = getIndexString(index,mapIndex)
                    
                    if ~containsFloat
                        if isempty(index)
                            % need this case because of the way sprintf is designed.
                            string = '< >';
                        else
                            string = sprintf('<%1d>',index);
                        end
                    else
                        string = sprintf('%1s  <%1d>', formatNumber(index),mapIndex);
                    end
                    
                end % getIndexString
                
            end % end of indexedFormatter
            
            
            %------------------------------------------------------------------------
            function [redStr,greenStr,blueStr] = getRGBColorStrings(colors,formatFcn)
                
                numColors = size(colors,1);
                
                if numColors == 0
                    redStr = {''};
                    greenStr = {''};
                    blueStr = {''};
                else
                    redStr = cell(numColors, 1);
                    greenStr = cell(numColors, 1);
                    blueStr = cell(numColors, 1);
                    
                    for k = 1 : numColors
                        redStr{k} = formatFcn(colors(k,1));
                        greenStr{k} = formatFcn(colors(k,2));
                        blueStr{k} = formatFcn(colors(k,3));
                    end
                end
                
            end % getRGBColorStrings
            
            
            %----------------------------------------------------------
            function pixelInfoString = getIntensityPixelInfoString(r,c)
                
                value = getValues(r,c);
                pixelInfoString = sprintf('%1s', formatNumber(value));
                
            end % getIntensityPixelInfoString
            
            
            %----------------------------------------------------------------
            function pixelRegionStrings = getIntensityPixelRegionStrings(r,c)
                
                pixelRegionStrings = cell(numel(r), 1);
                for k = 1:numel(r)
                    pixelRegionStrings{k} = getIntensityPixelInfoString(r(k), c(k));
                end
                
            end % getIntensityPixelRegionStrings
            
            
            %-------------------------------
            function values = getValues(r,c)
                
                img = get(imgmodel.ImageHandle,'CData');
                M = size(img, 1);
                if ~isempty(img)
                    values = img((c-1)*M + r);
                else
                    values = [];
                end
                
            end % getValues
            
            
            %--------------------------------------------
            function string = getDefaultPixelRegNumString
                
                switch getClassType(imgmodel)
                    case {'double','single'}
                        if ~containsFloat
                            %this could be data that was once int16
                            string = '-0.00E+00';
                        else
                            string = formatNumber(0);
                        end
                    case 'uint64'
                        string = repmat('0',1,20);
                    case 'int64'
                        string = strcat('-',repmat('0',1,19));
                    case 'uint32'
                        string = '0000000000';
                    case 'int32'
                        string = '-0000000000';
                    case 'uint16'
                        string = '00000';
                    case 'int16'
                        string = '-00000';
                    case 'uint8'
                        string = '000';
                    case 'int8'
                        string = '-000';
                    case 'logical'
                        string = '0';
                    otherwise
                        error(message('images:imagemodel:invalidClass'))
                end
                
            end % getDefaultPixelRegNumString
            
        end % end of getDataFromImageTypeFormatter
        
    end % private methods
    
end % imagemodel


%-----------------------------------
function hIm = parseInputs(varargin)

% assign default
hIm = [];

narginchk(0,1);

if nargin == 1
    hIm = varargin{1};
    
    if ~all(ishghandle(hIm)) || ~all(strcmp(get(hIm,'type'),'image'))
        error(message('images:imagemodel:invalidImageHandle'))
    end
end

end % parseInputs


%-------------------------------------------
function out_str = dispMapEntryFcn(mapEntry)
% This function used to be an anonymous function, but it was causing multiple
% instances of the object to be created.  This was due to the fact that
% anonymous function makes the parent workspace persist and act like nested
% functions.

% @(mapEntry) sprintf('%1.2f',mapEntry);

out_str = sprintf('%1.2f',mapEntry);

end % dispMapEntryFcn


%------------------------------------
function imgtype = findImageType(hIm)
%   IMGTYPE = FINDIMAGETYPE(hIm) returns the image type of the CData in
%   the image object.

iptcheckhandle(hIm,{'image'},mfilename,'HIM',1);

if ndims(get(hIm,'CData')) == 3
    imgtype = 'truecolor';
    
else
    if strcmp(get(hIm,'CDataMapping'),'direct')
        % Logical images with direct CDataMapping will  be assigned an
        % 'indexed' image type. This is desired behavior and is consistent with
        % HG for the case image(X,map) when X is logical.
        imgtype = 'indexed';
    else
        % 'scaled'
        % intensity or binary image
        if islogical(get(hIm,'Cdata'))
            imgtype = 'binary';
        else
            imgtype = 'intensity';
        end
    end
end

end % findImageType


%------------------------------------------------
function string = createStringForExponents(value)

string = sprintf('%1.2E', value);

end % createStringForExponents

