function varargout = getimage(varargin)
%GETIMAGE Get image data from axes.
%   A = GETIMAGE(H) returns the first image data contained in the Handle
%   Graphics object H.  H can be a figure, axes, or image. A is identical to
%   the image CData; it contains the same values and is of the same class
%   (uint8, uint16, double, or logical) as the image CData.  If H is not an
%   image or does not contain an image, A is empty.
%
%   [X,Y,A] = GETIMAGE(H) returns the image XData in X and the YData in
%   Y. XData and YData are two-element vectors that indicate the range of
%   the x-axis and y-axis.
%
%   [...,A,FLAG] = GETIMAGE(H) returns an integer flag that indicates the
%   type of image H contains. FLAG is one of these values:
%   
%       0   Not an image; A is returned as an empty matrix
%
%       1   Indexed image
%
%       2   Intensity image with CData values in standard range ([0,1] for
%           double arrays, [0,255] for uint8 arrays, [0,65535] for uint16 
%           arrays)
%
%       3   Intensity data, but not in standard range
%
%       4   RGB image
%
%       5   Binary image  
%
%   [...] = GETIMAGE returns information for the current axes. It is
%   equivalent to [...] = GETIMAGE(GCA).
%
%   Class Support
%   -------------
%   The output array A is of the same class as the image CData. All other
%   inputs and outputs are of class double.
%
%   Note
%   ----  
%   For int16 and single images, the image data returned by getimage is of
%   class double, not int16 or single. The getimage function queries the
%   image object's CData property for the image data and image objects store
%   int16 and single image data as class double.
%
%   For an image of class int16, 
%
%      h = imshow(ones(10,'int16)); 
%      class(get(h,'CData'))
%
%   class returns double. Therefore, using the syntax,
%
%      [img,flag] = getimage(h);
%      class(img)
%
%   also returns an image of class double, with flag set to 3. 
%
%   For an image of class single, 
%
%      h = imshow(ones(10,'single'));
%      class(get(h,'CData')) 
%
%   class returns double. Therefore, using the syntax, 
%
%      [img,flag] = getimage(h);
%      class(img)
%
%   also returns an image of class double, with flag set to 2, because
%   single and double share the same range.
%
%   Examples
%   --------
%   After using IMSHOW or IMTOOL to display an image directly from a file, use
%   GETIMAGE to get the image data into the workspace.
%
%       imshow rice.png
%       I = getimage;
%  
%       imtool cameraman.tif
%       I = getimage(imgca);
%
%   See also IMSHOW, IMTOOL.

%   Copyright 1993-2014 The MathWorks, Inc.  

him = parseInputs(varargin{:});

if (isempty(him))
    % We didn't find an image.
    x = [];
    y = [];
    A = [];
    state = 0;
    
elseif (strcmp(get(him, 'Type'), 'surface'))
    % We found a texturemapped surface object.
    A = get(him, 'CData');
    x = get(him, 'XData');
    y = get(him, 'YData');
    state = 2;
    
else
    %image
    [x,y,A,state] = getInfoOnImage(him);
end    
   
switch nargout
case 0
    % GETIMAGE(...)
    varargout{1} = A;
    
case 1
    % A = GETIMAGE(...)
    varargout{1} = A;
    
case 2
    % [A,FLAG] = GETIMAGE(...)
    varargout{1} = A;
    varargout{2} = state;
    
case 3
    % [x,y,A] = GETIMAGE(...)
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = A;
    
case 4
    % [x,y,A,FLAG] = GETIMAGE(...)
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = A;
    varargout{4} = state;
    
otherwise
    error(message('images:getimage:tooManyOutputArgs'))
    
end 
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y,A,state] = getInfoOnImage(him)

userdata = get(him, 'UserData');
cdatamapping = get(him, 'CDataMapping');
x = getXData(him);
y = getYData(him);
A = get(him, 'CData');

if islogical(A)
    state = 5; %logical image
    
elseif ((ndims(A) == 3) && (size(A,3) == 3))
    % We have an RGB image
    state = 4;
    
else
    % Not an RGB image
    
    if (isequal(cdatamapping,'direct'))
        % Do we have an indexed image or an old-style intensity
        % or scaled image?
        
        if (isequal(size(userdata), [1 2]))
            % We have an old-style intensity or scaled image.
            
            % How long is the colormap?
            hfig = ancestor(him,'figure');
            N = size(get(hfig,'Colormap'),1);
            
            if (isequal(userdata, [0 1]))
                % We have an old-style intensity image.
                A = (A-1)/(N-1);
                state = 2;
                
            else
                % We have an old-style scaled image.
                A = (A-1)*((userdata(2)-userdata(1))/(N-1))+userdata(1);
                state = 3;
                
            end
            
        else
            % We have an indexed image.
            state = 1;
        end

    else
        % CDataMapping is 'scaled'
        
        hax = ancestor(him, 'axes');
        clim = get(hax, 'CLim');
        range = getrangefromclass(A);
        classA = class(A);
        
        supportedHGDataTypes = {'double', 'single','uint8', 'int8','uint16','int16','uint32','int32'};
        
        if any(strncmp(classA, supportedHGDataTypes, ...
                length(classA))) && isequal(clim, range)
            % We have an intensity image.
            state = 2;
            
        else
            % We have a scaled image.
            state = 3;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function him = parseInputs(varargin)

narginchk(0,1);

if nargin==1
    h = varargin{1};
    if (~ishghandle(h))
        error(message('images:getimage:invalidHandleH'))
    end
else
    h = gca;
end

him = imhandles(h);

if numel(him)>0
    % Found more than one image in the axes.
    % If one of the images is the current object, use it.
    % Otherwise, use the first image in the stacking order.
    hfig = ancestor(h,'figure');
    currentObj = get(hfig, 'CurrentObject');
    if (isempty(currentObj))
        % No current object; use the one on top.
        him = him(1);
    else
        % If the current object is one of the images
        % we found, use it.
        idx = find(him == currentObj);
        if (isempty(idx))
            him = him(1);
        else
            him = him(idx);
        end
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xdata = getXData(handle)

xdata = get(handle,'XData');

if isscalar(xdata)
    xdata = [xdata xdata];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ydata = getYData(handle)

ydata = get(handle,'YData');

if isscalar(ydata)
    ydata = [ydata ydata];
end
