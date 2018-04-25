function value = graysampler(imageHandle)
%GRAYSAMPLER Returns grayscale value of pixel after a button press.
%   VALUE = GRAYSAMPLER(IMAGEHANDLE) returns a grayscale value from an
%   image with a handle of IMAGEHANDLE.  The value will be the intensity of
%   the pixel under the cursor when a mouse button is pressed.
%
%   This function is used by IMCONTRAST.
  
%   Copyright 2005 The MathWorks, Inc.
%   

hImageAx = ancestor(imageHandle, 'axes');
hFig = ancestor(imageHandle, 'figure');

figure(hFig);

% Set button behavior.
bdfID = iptaddcallback(imageHandle, 'ButtonDownFcn', @getSample);

% Set Key Press to cancel out of value picker
kpressID = iptaddcallback(hFig, 'KeyPressFcn', @getSample);

% Initialize value
value = [];
uiwait(hFig);

    %==========================
    function getSample(varargin)
        
        % determine if the escape key was pressed
        if ~isempty(varargin{2}) && (isfield(varargin{2}, 'Key') || ...
                                     isprop(varargin{2}, 'Key'))
                                 
            if strcmpi(varargin{2}.Key, 'escape')
                % continue to cleanup code
            else
                % ignore
                return
            end
            
        else
            
            currentPoint = round(get(hImageAx, 'CurrentPoint'));
            
            cData = get(imageHandle, 'CData');
            
            value = cData(currentPoint(1,2), currentPoint(1,1), :);
            value = value(:)';
            
        end
        
        % Unset the key press
        iptremovecallback(hFig, 'KeyPressFcn', kpressID);
        
        % Unset the button behavior.
        iptremovecallback(imageHandle, 'ButtonDownFcn', bdfID);
        
        uiresume(hFig);
        
    end

end
