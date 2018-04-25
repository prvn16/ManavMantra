function varargout = iswt2(varargin)
%ISWT2 Inverse stationary wavelet transform 2-D.
%   X = ISWT2(SWC,WNAME) synthesizes the matrix X from the stationary
%   wavelet transform coefficients in SWC. ISWT2 uses the orthogonal or
%   biorthogonal wavelet, WNAME, in the reconstruction. WNAME is a
%   character array recognized by WAVEMNGR and must match the wavelet used
%   in the analysis SWT2.
%
%   X = ISWT2(A,H,V,D,WNAME) synthesizes the matrix X from the
%   approximation and wavelet coefficients matrices, A, H, V, and D.
%   A, H, V, and D are outputs of SWT2.
%   
%   [...] = ISWT2(...,LoR,HiR) uses the scaling and wavelet synthesis
%   filters, LoR and HiR, in the reconstruction. LoR and HiR must be
%   even-length row or column vectors and must be equal in length. ISWT2
%   does not check LoR and HiR to ensure that they are valid reconstruction
%   filters.
%
%   %Example
%   im = imread('noisarms.jpg');
%   swc = swt2(im,3,'db2');
%   imrec = iswt2(swc,'db2');
%   image(uint8(imrec))
%   max(abs(uint8(imrec(:))-im(:)))
%
%   See also IDWT2, SWT2, WAVEREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Dec-97.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Check arguments.
narginchk(2,6);

nbIn = nargin;
if nbIn == 4
    error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
end

switch nbIn
    case 2 , argstr = 1; argnum = 2;
    case 3 , argstr = 0; argnum = 2;
    case 5 , argstr = 1; argnum = 5;
    case 6 , argstr = 0; argnum = 5;
end

% Compute reconstruction filters.
if argstr && ischar(varargin{argnum})
    wtype = wavemngr('type',varargin{argnum});
    if ~any(wtype == [1 2])
        error(message('Wavelet:FunctionInput:OrthorBiorthWavelet'));
    end
    [lo_R,hi_R] = wfilters(varargin{argnum},'r');
else
    if nargin < argnum+1
        error(message('Wavelet:FunctionInput:InvalidLoHiFilters'));
    end
    lo_R = varargin{argnum};
    hi_R = varargin{argnum+1};
    
    validateattributes(lo_R,{'numeric'},...
        {'vector','finite','real'},'iswt2','Lo_R',argnum);
    validateattributes(hi_R,{'numeric'},...
        {'vector','finite','real'},'iswt2','Hi_R',argnum+1);
    
    % The filters must have an even length greater than 2.
    if (length(lo_R) < 2) || (length(hi_R) < 2) || ...
            mod(length(lo_R),2) || mod(length(hi_R),2)
        error(message('Wavelet:FunctionInput:Invalid_Filt_Length'));
    end
end


% Get inputs.

if nargin == 2
    isSeparateMatrices = false;
elseif nargin == 3 && isvector(varargin{2}) && isvector(varargin{3})
    isSeparateMatrices = false;
else
    isSeparateMatrices = true;
end
sX = size(varargin{1});
lenSX = length(sX);
% Determine if the coefficient matrices came from an RGB image
a3d_Flag = isRGBData(sX,isSeparateMatrices);

if a3d_Flag
    nbColon = 3;
else
    nbColon = 2;
end  % max([lenSX-1,2])
idxColon = repmat({':'},1,nbColon);
S.type = '()';
Ambiguity = false;
if argnum==2
    nbRows = size(varargin{1},lenSX);
    if rem(nbRows,3)==1
        level = (nbRows-1)/3;
    else
        error(message('Wavelet:FunctionInput:InvalidSwcSize'));
    end
    SWC = varargin{1};
    if a3d_Flag
        SWC = squeeze(SWC);
    end
    validateattributes(SWC, {'double'}, {'real','finite','nonempty'},...
        'iswt2', 'SWC', 1);
    S.subs = [idxColon,1:level];
    h = subsref(SWC,S);
    S.subs = [idxColon,level+1:2*level];
    v = subsref(SWC,S);
    S.subs = [idxColon,2*level+1:3*level];
    d = subsref(SWC,S);
    S.subs = [idxColon,3*level+1:nbRows];
    a = subsref(SWC,S);
else
    a = varargin{1};
    h = varargin{2};
    v = varargin{3};
    d = varargin{4};
    if a3d_Flag
        a = squeeze(a);
        h = squeeze(h);
        v = squeeze(v);
        d = squeeze(d);
    end
    
    % Coefficient matrices must be double-precision
    validateattributes(a, {'double'}, {'real','finite'}, 'iswt2', 'A', 1);
    validateattributes(h, {'double'}, {'real','finite'}, 'iswt2', 'H', 2);
    validateattributes(v, {'double'}, {'real','finite'}, 'iswt2', 'V', 3);
    validateattributes(d, {'double'}, {'real','finite'}, 'iswt2', 'D', 4);
    %----------------------------------------------------------------------
    % Ambiguity:
    % (level=3 and indexed BW image) or (level=1 and truecolor image)
    % To suppress this Ambiguity, the function SWT2 in case of a true
    % color image and a level 1 analysis, produce single for approximation
    % coefficients !!
    %----------------------------------------------------------------------
    % if ~a3d_Flag
    %     if size(a,3)==3 && size(h,3)==3 && size(v,3)==3 && size(d,3)==3
    %         a3d_Flag = true;
    %         Ambiguity = true;
    %     end
    % end
    %----------------------------------------------------------------------
end
[rx,cx,dim3,dim4] = size(h);

% Extract last approximation coefficients
if ~Ambiguity
    if a3d_Flag
        idxApp = size(a,4);
    else
        idxApp = size(a,3);
    end
    S.subs = [idxColon,idxApp];
    a  = subsref(a,S);
else  % do nothing
    error(message('Wavelet:FunctionToVerify:LastApp'));
end

if ~a3d_Flag
    level = dim3;
    a = reconsLOC(a,h,v,d);
else
    level = dim4;
    tmp = cell(1,3);
    for j=1:3
        tmp{j} = reconsLOC(a(:,:,j),h(:,:,j,:),v(:,:,j,:),d(:,:,j,:));
    end
    a = cat(3,tmp{:});
    
end

varargout{1} = a;

%--------------------------------------------------------------------
    function ca = reconsLOC(ca,ch,cv,cd)
        for k = level:-1:1
            step = 2^(k-1);
            last = step;
            for first = 1:last
                iRow = first:step:rx;
                lR   = length(iRow);
                iCol = first:step:cx;
                lC   = length(iCol);
                
                sR   = iRow(1:2:lR);
                sC   = iCol(1:2:lC);
                x1   = idwt2LOC(...
                    ca(sR,sC),ch(sR,sC,k),cv(sR,sC,k),cd(sR,sC,k), ...
                    lo_R,hi_R,[lR lC],[0,0]);
                
                sR   = iRow(2:2:lR);
                sC   = iCol(2:2:lC);
                x2   = idwt2LOC(...
                    ca(sR,sC),ch(sR,sC,k),cv(sR,sC,k),cd(sR,sC,k), ...
                    lo_R,hi_R,[lR lC],[-1,-1]);
                ca(iRow,iCol) = 0.5*(x1+x2);
            end
        end
    end
%--------------------------------------------------------------------

end


%===============================================================%
% INTERNAL FUNCTIONS
%===============================================================%
function y = idwt2LOC(a,h,v,d,lo_R,hi_R,sy,shift)

y = upconvLOC(a,lo_R,lo_R,sy)+ ... % Approximation.
    upconvLOC(h,hi_R,lo_R,sy)+ ... % Horizontal Detail.
    upconvLOC(v,lo_R,hi_R,sy)+ ... % Vertical Detail.
    upconvLOC(d,hi_R,hi_R,sy);     % Diagonal Detail.

if shift(1)==-1 , y = y([end,1:end-1],:); end
if shift(2)==-1 , y = y(:,[end,1:end-1]); end
end
%---------------------------------------------------------------%
function y = upconvLOC(x,f1,f2,s)

lf = length(f1);
y  = dyadup(x,'mat',0,1);
y  = wextend('2D','per',y,[lf/2,lf/2]);
y  = wconv2('col',y,f1);
y  = wconv2('row',y,f2);
y  = wkeep2(y,s,[lf lf]);
end
%===============================================================%
function TF = isRGBData(sizes,isSeparateMatrices)
% Determine whether the input to swt2 was an RGB image
if length(sizes) == 4 && sizes(3) == 3 
    TF = true;
elseif length(sizes) == 4 && sizes(3) == 1 && sizes(4) == 3 && ...
        isSeparateMatrices
    TF = true;
else
    TF = false;
end

end



