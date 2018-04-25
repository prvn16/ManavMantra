function visualize(farfieldsignal, titleStr)

farfieldintensity = real( farfieldsignal .* conj( farfieldsignal ) );
imagesc( fftshift( farfieldintensity ) );
axis( 'equal' ); axis( 'off' );
title(titleStr);

end