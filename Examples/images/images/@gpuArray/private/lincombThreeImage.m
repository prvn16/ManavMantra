function out = lincombThreeImage(x,y,z,k1,k2,k3,k0)
%LINCOMBTHREEIMAGE used by imlincomb.
%   Private helper function to compute a three-image linear combination.
out = k0 + k1*double(x) + k2*double(y) + k3*double(z);