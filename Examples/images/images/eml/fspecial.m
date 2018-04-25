function h = fspecial(varargin) %#codegen
% Copyright 2010-2017 The MathWorks, Inc.

coder.extrinsic('eml_try_catch');

% Check the number of input arguments.
narginchk(1,3);

coder.internal.prefer_const(varargin);

% Determine filter type from the user supplied string and check if constant.
eml_invariant(eml_is_const(varargin{1}),...
            eml_message('MATLAB:images:validate:codegenInputNotConst','TYPE'), ...
            'IfNotConst','Fail');
type = varargin{1};
type = validatestring(type,{'gaussian','sobel','prewitt','laplacian','log',...
    'average','unsharp','disk','motion'},mfilename,'TYPE',1);

if ((nargin == 1) ||(nargin==2 && eml_is_const(varargin{2})) || ...
        (nargin==3 && eml_is_const(varargin{2}) && eml_is_const(varargin{3}))) 
    % Constant fold
    [errid,errmsg,h] = eml_const(eml_try_catch('fspecial',varargin{:}));
    eml_lib_assert(isempty(errmsg),errid,errmsg);
else
    % Generate code
    switch type
        case 'average' % Smoothing filter
            % FSPECIAL('average',N)
            coder.internal.errorIf((nargin==3),'images:fspecial:tooManyArgsForThisFilter');
            Hsize = varargin{2};
            validateattributes(Hsize,{'double'},...
                {'positive','finite','real','nonempty','integer'},...
                mfilename,'HSIZE',2);
            
            coder.internal.errorIf(numel(Hsize) > 2,'images:fspecial:wrongSizeHSize');
            if numel(Hsize)==1
                p2 = [Hsize Hsize];
            else
                p2 = Hsize;
            end
            h = ones(p2(1:2))/prod(p2(1:2));
            
        case 'disk' % Disk filter
            % FSPECIAL('disk',RADIUS)
            coder.internal.errorIf((nargin==3),'images:fspecial:tooManyArgsForThisFilter');
            rad = varargin{2};
            validateattributes(rad,{'double'},...
                {'positive','finite','real','nonempty','scalar'},...
                mfilename,'RADIUS',2);
            
            crad  = ceil(rad-0.5);
            [x,y] = meshgrid(-crad:crad,-crad:crad);
            maxxy = max(abs(x),abs(y));
            minxy = min(abs(x),abs(y));
            m1c = (rad^2 >= (maxxy+0.5).^2 + (minxy-0.5).^2).* ...
                sqrt(complex(rad^2 - (maxxy + 0.5).^2));
            m1 = (rad^2 <  (maxxy+0.5).^2 + (minxy-0.5).^2).*(minxy-0.5) + m1c;
            m2c = (rad^2 <= (maxxy-0.5).^2 + (minxy+0.5).^2).* ...
                sqrt(complex(rad^2 - (maxxy - 0.5).^2));
            m2 = (rad^2 >  (maxxy-0.5).^2 + (minxy+0.5).^2).*(minxy+0.5) + m2c;
            sgrid = (rad^2*(0.5*(asin(m2/rad) - asin(m1/rad)) + ...
                0.25*(sin(2*asin(m2/rad)) - sin(2*asin(m1/rad)))) - ...
                (maxxy-0.5).*(m2-m1) + (m1-minxy+0.5)) ...
                .*((((rad^2 < (maxxy+0.5).^2 + (minxy+0.5).^2) & ...
                (rad^2 > (maxxy-0.5).^2 + (minxy-0.5).^2)) | ...
                ((minxy==0)&(maxxy-0.5 < rad)&(maxxy+0.5>=rad))));
            sgrid = sgrid + ((maxxy+0.5).^2 + (minxy+0.5).^2 < rad^2);
            sgrid(crad+1,crad+1) = min(pi*rad^2,pi/2);
            if ((crad>0) && (rad > crad-0.5) && (rad^2 < (crad-0.5)^2+0.25))
                m1  = sqrt(rad^2 - (crad - 0.5).^2);
                m1n = m1/rad;
                sg0 = 2*(rad^2*(0.5*asin(m1n) + 0.25*sin(2*asin(m1n)))-m1*(crad-0.5));
                sgrid(2*crad+1,crad+1) = sg0;
                sgrid(crad+1,2*crad+1) = sg0;
                sgrid(crad+1,1)        = sg0;
                sgrid(1,crad+1)        = sg0;
                sgrid(2*crad,crad+1)   = sgrid(2*crad,crad+1) - sg0;
                sgrid(crad+1,2*crad)   = sgrid(crad+1,2*crad) - sg0;
                sgrid(crad+1,2)        = sgrid(crad+1,2)      - sg0;
                sgrid(2,crad+1)        = sgrid(2,crad+1)      - sg0;
            end
            sgrid(crad+1,crad+1) = min(sgrid(crad+1,crad+1),1);
            h = sgrid/sum(sgrid(:));
            
        case 'gaussian' % Gaussian filter
            % FSPECIAL('gaussian',N)
            % FSPECIAL('gaussian',N,SIGMA)
            if (nargin==2)
                N = varargin{2};
                p3 = 0.5;    % std
                validateattributes(N,{'double'},...
                    {'positive','finite','real','nonempty','integer'},...
                    mfilename,'N',2);
                coder.internal.errorIf(numel(N) > 2,'images:fspecial:wrongSizeHSize');
                if numel(N)==1
                    p2 = [N N];
                else
                    p2 = N;
                end
            elseif (nargin==3)
                N = varargin{2};
                Sigma = varargin{3};
                validateattributes(N,{'double'},...
                    {'positive','finite','real','nonempty','integer'},...
                    mfilename,'N',2);
                validateattributes(Sigma,{'double'},...
                    {'positive','finite','real','nonempty','scalar'},...
                    mfilename,'SIGMA',3);
                coder.internal.errorIf(numel(N) > 2,'images:fspecial:wrongSizeN');
                if numel(N)==1
                    p2 = [N N];
                else
                    p2 = N;
                end
                p3 = Sigma;
            end
            siz   = (p2-1)/2;
            std   = p3;
            [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
            arg   = -(x.*x + y.*y)/(2*std*std);
            h     = exp(arg);
            h(h<eps*max(h(:))) = 0;
            sumh = sum(h(:));
            if sumh ~= 0,
                h  = h/sumh;
            end;
            
        case 'laplacian' % Laplacian filter
            % FSPECIAL('laplacian',ALPHA)
            coder.internal.errorIf((nargin==3),'images:fspecial:tooManyArgsForThisFilter');
            p2 = varargin{2};
            validateattributes(p2,{'double'},{'nonnegative','real',...
                'nonempty','finite','scalar'},...
                mfilename,'ALPHA',2);
            %p2 can have more than 1 element (like gaussian)
            coder.internal.errorIf(p2(1) > 1,'images:fspecial:outOfRangeAlpha');
            
            alpha = max(0,min(p2(1),1));
            h1    = alpha/(alpha+1); h2 = (1-alpha)/(alpha+1);
            h     = [h1 h2 h1;h2 -4/(alpha+1) h2;h1 h2 h1];
            
        case 'unsharp' % Unsharp filter
            % FSPECIAL('unsharp',ALPHA)
            coder.internal.errorIf((nargin==3),'images:fspecial:tooManyArgsForThisFilter');
            alpha = varargin{2};
            validateattributes(alpha,{'double'},{'nonnegative','real',...
                'nonempty','finite','scalar'},...
                mfilename,'ALPHA',2);
            %p2 can have more than 1 element (like gaussian)
            coder.internal.errorIf(alpha(1) > 1,'images:fspecial:outOfRangeAlpha');
            
            h     = [0 0 0;0 1 0;0 0 0] - fspecial('laplacian',alpha);
            
        case 'log' % Laplacian of Gaussian
            % FSPECIAL('log',N)
            % FSPECIAL('log',N,SIGMA)
            if (nargin==2)
                N = varargin{2};
                p3 = 0.5;
                validateattributes(N,{'double'},...
                    {'positive','finite','real','nonempty','integer'},...
                    mfilename,'N',2);
                coder.internal.errorIf(numel(N) > 2,'images:fspecial:wrongSizeHSize');
                if numel(N)==1
                    p2 = [N N];
                else
                    p2 = N;
                end
            else
                N = varargin{2};
                Sigma = varargin{3};
                validateattributes(N,{'double'},...
                    {'positive','finite','real','nonempty','integer'},...
                    mfilename,'N',2);
                validateattributes(Sigma,{'double'},...
                    {'positive','finite','real','nonempty','scalar'},...
                    mfilename,'SIGMA',3);
                coder.internal.errorIf(numel(N) > 2,'images:fspecial:wrongSizeN');
                if numel(N)==1
                    p2 = [N N];
                else
                    p2 = N;
                end
                p3 = Sigma;
            end
            % first calculate Gaussian
            siz   = (p2-1)/2;
            std2   = p3^2;
            
            [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
            arg   = -(x.*x + y.*y)/(2*std2);
            
            h     = exp(arg);
            h(h<eps*max(h(:))) = 0;
            
            sumh = sum(h(:));
            if sumh ~= 0,
                h  = h/sumh;
            end;
            % now calculate Laplacian
            h1 = h.*(x.*x + y.*y - 2*std2)/(std2^2);
            h     = h1 - sum(h1(:))/prod(p2(1:2)); % make the filter sum to zero
            
        case 'motion'
            % FSPECIAL('motion',LEN)
            % FSPECIAL('motion',LEN,THETA)
            if (nargin==2)
                p2 = varargin{2};
                p3 = 0;
                validateattributes(p2,{'double'},...
                    {'positive','finite','real','nonempty','scalar'},...
                    mfilename,'LEN',2);
            else
                p2 = varargin{2};
                p3 = varargin{3};
                validateattributes(p2,{'double'},...
                    {'positive','finite','real','nonempty','scalar'},...
                    mfilename,'LEN',2); %#ok<*EMCA>
                validateattributes(p3,{'double'},...
                    {'real','nonempty','finite','scalar'},...
                    mfilename,'THETA',3);
            end
            len = max(1,p2);
            half = (len-1)/2;% rotate half length around center
            phi = mod(p3(1),180)/180*pi;
            
            cosphi = cos(phi);
            sinphi = sin(phi);
            xsign = sign(cosphi);
            linewdt = 1;
            
            % define mesh for the half matrix, eps takes care of the right size
            % for 0 & 90 rotation
            sx = fix(half*cosphi + linewdt*xsign - len*eps);
            sy = fix(half*sinphi + linewdt - len*eps);
            [x, y] = meshgrid(0:xsign:sx, 0:sy);
            
            % define shortest distance from a pixel to the rotated line
            dist2line = (y*cosphi-x*sinphi);% distance perpendicular to the line
            
            rad = sqrt(x.^2 + y.^2);
            % find points beyond the line's end-point but within the line width
            
            linepix = coder.nullcopy(zeros(size(rad)));
            for idx = 1:numel(rad)
                linepix(idx) = (((rad(idx) >= half))&(abs(dist2line(idx))<= linewdt));
            end
            
            % Replacement for find
            numElems = nnz(linepix);
            lastpix  = coder.nullcopy(zeros(1, numElems));
            index = 1;
            for i = 1:numel(linepix)
                if(linepix(i))
                    lastpix(index) = i;
                    index = index + 1;
                end
            end
            
            %distance to the line's end-point parallel to the line
            lastpixdist = abs((x(lastpix) + dist2line(lastpix)*sinphi)/cosphi);
            x2lastpix = half - lastpixdist;
            
            dist2line(lastpix) = sqrt(dist2line(lastpix).^2 + x2lastpix.^2);
            dist2line = linewdt + eps - abs(dist2line);
            dist2line(dist2line<0) = 0;% zero out anything beyond line width
            
            % unfold half-matrix to the full size
            h = zeros(2*size(dist2line,1)-1, 2*size(dist2line,2)-1);
            h(1:size(dist2line,1),1:size(dist2line,2)) = rot90(dist2line,2);
            h(size(dist2line,1)+(1:size(dist2line,1))-1, size(dist2line,2)+(1:size(dist2line,2))-1) = dist2line;
            sumh = sum(h(:)) + eps*len*len;
            
            for idx = 1:numel(h)
                h(idx) = h(idx)/sumh;
            end
            
            if cosphi>0,
                h = flipud(h);
            end
    end
end
