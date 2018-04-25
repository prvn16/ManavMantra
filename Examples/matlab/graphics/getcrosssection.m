function crossX = getcrosssection(c_position1,c_position2,eUp)
% This internal helper function may change in a future release.

% CROSSX = GETCROSSSECTION(OBJ,POSITION1,POSITION2,EUP) 
% OBJ is an axes child.
% POSITION1, POSITION2 are axes rays as if produced by the 'CurrentPoint'
%        AXES property representing opposite corners of a prism.
% Returns a matrix which defines the cross-section of the prism whose
%        opposite vertices intersect the axes rays POSITION1 and POSITION2. 
%        The two rows of this matrix define the positions of adjacent prism 
%        vertices relative to the prism vertex defined by the first row of
%        POSITION1.

%   Copyright 2008 The MathWorks, Inc.

a = c_position1(1,:);
d = c_position1(2,:);
b = c_position2(1,:);
c = c_position2(2,:);

% Find O,Oprime axes
% The front cross-section is between the camera and the axes box
O = a;
lambda = (a-c)*(a-d)'/((a-d)*(c-b)');
Oprime = lambda*(c-b)+c;

% Find the cross-section corners S,S'
N = cross(a-d,eUp(:));
U = N*((a-Oprime)*N')/(N*N');
S = a-U;
Sprime = Oprime+U;

% Find the cross-section
crossX = [S-O;...
          Sprime-O];
    
     
     