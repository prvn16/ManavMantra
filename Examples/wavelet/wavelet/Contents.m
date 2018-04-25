% Wavelet Toolbox
% Version 5.0 (R2018a) 06-Feb-2018
%
% Wavelet Toolbox GUI (Graphical User Interface).
%   waveletAnalyzer - Start Wavelet Analyzer graphical user interface tools
%
% Wavelets: General
%   biorfilt        - Biorthogonal wavelet filter set
%   centfrq         - Wavelet center frequency
%   dyaddown        - Dyadic downsampling
%   cwtfilterbank   - CWT filter bank
%   dwtfilterbank   - DWT filter bank
%   dyadup          - Dyadic upsampling
%   intwave         - Integrate wavelet function psi
%   orthfilt        - Orthogonal wavelet filter set
%   qmf             - Quadrature mirror filter
%   scal2frq        - Scale to frequency
%   wavefun         - Wavelet and scaling functions
%   wavefun2        - Wavelets and scaling functions 2-D
%   wavemngr        - Wavelet manager 
%   wfilters        - Wavelet filters
%   wmaxlev         - Maximum wavelet decomposition level
%
% Wavelet Families
%   biorwavf        - Biorthogonal spline wavelet filters
%   cgauwavf        - Complex Gaussian wavelet
%   cmorwavf        - Complex Morlet wavelet
%   coifwavf        - Coiflet wavelet filter
%   dbaux           - Daubechies wavelet filter computation
%   dbwavf          - Daubechies wavelet filters
%   fbspwavf        - Complex Frequency B-Spline wavelet
%   fejerkorovkin   - Fejer-Korovkin wavelet filters
%   gauswavf        - Gaussian wavelet
%   mexihat         - Mexican Hat wavelet
%   meyer           - Meyer wavelet
%   meyeraux        - Meyer wavelet auxiliary function
%   morlet          - Morlet wavelet
%   rbiowavf        - Reverse Biorthogonal spline wavelet filters
%   shanwavf        - Complex Shannon wavelet
%   symaux          - Symlet wavelet filter computation
%   symwavf         - Symlet wavelet filter
%
% Time-Frequency Analysis/Synthesis
%   cqt             - Constant-Q transform using nonstationary Gabor frames
%   icqt            - Inverse constant-q transform using nonstationary Gabor frames
%   cwtft           - Continuous wavelet transform using DFT
%   cwtftinfo       - Information on wavelets for CWTFT
%   cwtfreqbounds   - CWT maximum and minimum period or frequency 
%   cwt             - Continuous wavelet transform
%   icwt            - Inverse continuous wavelet transform
%   pat2cwav        - Construction of a wavelet starting from a pattern
%   wcoherence      - Wavelet coherence
%   wsst            - Wavelet synchrosqueezing transform
%   iwsst           - Inverse wavelet synchrosqueezing transform
%   wsstridge       - Time-frequency ridges from wavelet synchrosqueezing
%   wtmm            - Wavelet transform modulus maxima
%   cwtfilterbank   - CWT filter bank
%   wscalogram      - Scalogram for continuous wavelet transform
%   emd             - Empirical mode decomposition
%   hht             - Hilbert-Huang transform
%
% Continuous Wavelet: Two-Dimensional
%   cwtft2      - 2-D Continuous wavelet transform
%   cwtftinfo2  - Information on wavelets for CWTFT2
%
% Discrete Wavelets: One-Dimensional
%   appcoef         - Extract 1-D approximation coefficients
%   detcoef         - Extract 1-D detail coefficients
%   dwt             - Single-level discrete 1-D wavelet transform
%   dwtfilterbank   - DWT filter bank
%   dwtmode         - Discrete wavelet transform extension mode
%   idwt            - Single-level inverse discrete 1-D wavelet transform
%   haart           - Haar 1-D transform
%   ihaart          - Inverse Haar 1-D transform
%   upcoef          - Direct reconstruction from 1-D wavelet coefficients
%   upwlev          - Single-level reconstruction of 1-D wavelet decomposition
%   wavedec         - Multilevel 1-D wavelet decomposition
%   waverec         - Multilevel 1-D wavelet reconstruction
%   wenergy         - Energy for 1-D wavelet decomposition
%   wrcoef          - Reconstruct single branch from 1-D wavelet coefficients
%
% Maximal Overlap Discrete Wavelet Transform
%   modwt 		- Maximal overlap discrete wavelet transform
%   imodwt		- Inverse maximal overlap discrete wavelet transform
%	modwtmra	- Maximal overlap discrete wavelet transform MRA
%	modwtcorr	- Maximal overlap discrete wavelet transform correlation
%	modwtvar	- Maximal overlap discrete wavelet transform variance
%	modwtxcorr	- Maximal overlap discrete wavelet transform cross-correlation sequences
%
% Maximal Overlap Discrete Wavelet Packet Transform
%   modwpt          -   Maximal overlap discrete wavelet packet transform
%   imodwpt         -   Inverse maximal overlap discrete wavelet packet transform
%   modwptdetails   -   Maximal overlap discrete wavelet packet details
%
% Multiscale Local Polynomial Transform: One-Dimensional
%   mlpt            -   Multiscale local polynomial transform
%   imlpt           -   Inverse multiscale local polynomial transform
%   mlptrecon       -   Multiscale 1-D Local Polynomial Transform Reconstruction 
%   mlptdenoise     -   Denoising using the Multiscale local 1-D Polynomial Transform
%   
% Discrete Wavelets: Two-Dimensional
%   appcoef2    - Extract 2-D approximation coefficients
%   detcoef2    - Extract 2-D detail coefficients
%   dwt2        - Single-level discrete 2-D wavelet transform
%   dwtmode     - Discrete wavelet transform extension mode
%	haart2		- Haar 2-D transform
%   idwt2       - Single-level inverse discrete 2-D wavelet transform
%	ihaart2		- Inverse Haar 2-D transform
%   upcoef2     - Direct reconstruction from 2-D wavelet coefficients
%   upwlev2     - Single-level reconstruction of 2-D wavelet decomposition
%   wavedec2    - Multi-level 2-D wavelet decomposition
%   waverec2    - Multi-level 2-D wavelet reconstruction
%   wenergy2    - Energy for 2-D wavelet decomposition
%   wrcoef2     - Reconstruct single branch from 2-D wavelet coefficients
%
% Discrete Wavelets: Three-Dimensional
%   dwt3        - Single-level discrete 3-D wavelet transform
%   dwtmode     - Discrete wavelet transform extension mode
%   idwt3       - Single-level inverse discrete 2-D wavelet transform
%   wavedec3    - Multi-level 3-D wavelet decomposition
%   waverec3    - Multi-level 3-D wavelet reconstruction
%
% Wavelets Packets Algorithms
%   bestlevt    - Best level tree (wavelet packet)
%   besttree    - Best tree (wavelet packet)
%   entrupd     - Entropy update (wavelet packet)
%   wenergy     - Energy for a wavelet packet decomposition
%   wentropy    - Entropy (wavelet packet)
%   wp2wtree    - Extract wavelet tree from wavelet packet tree
%   wpcoef      - Wavelet packet coefficients
%   wpcutree    - Cut wavelet packet tree
%   wpdec       - Wavelet packet decomposition 1-D
%   wpdec2      - Wavelet packet decomposition 2-D
%   wpfun       - Wavelet packet functions
%   wpjoin      - Recompose wavelet packet
%   wprcoef     - Reconstruct wavelet packet coefficients
%   wprec       - Wavelet packet reconstruction 1-D 
%   wprec2      - Wavelet packet reconstruction 2-D
%   wpsplt      - Split (decompose) wavelet packet
%
% Discrete Stationary Wavelet Transform Algorithms
%   iswt        - Inverse discrete stationary wavelet transform 1-D
%   iswt2       - Inverse discrete stationary wavelet transform 2-D
%   swt         - Discrete stationary wavelet transform 1-D
%   swt2        - Discrete stationary wavelet transform 2-D
%
% Multisignal Wavelet Analysis: One-Dimensional
%   chgwdeccfs  - Change Multisignal 1-D decomposition coefficients
%   mdwtdec     - Multisignal 1-D wavelet decomposition 
%   mdwtrec     - Multisignal 1-D wavelet reconstruction 
%   mswcmp      - Multisignal 1-D compression using wavelets 
%   mswcmpscr   - Multisignal 1-D wavelet compression scores
%   mswcmptp    - Multisignal 1-D compression thresholds and performances
%   mswden      - Multisignal 1-D denoising using wavelets 
%   mswthresh   - Performs Multisignal 1-D thresholding 
%   wdecenergy  - Multisignal 1-D decomposition energy repartition 
%   wmspca      - Multiscale principal component analysis 
%   wmulden     - Wavelet multivariate 1-D denoising 
%
% Lifting Functions
%   addlift     - Adding primal or dual lifting steps
%   bswfun      - Biorthogonal scaling and wavelet functions
%   displs      - Display lifting scheme
%   filt2ls     - Filters to lifting scheme
%   ilwt        - Inverse 1-D lifting wavelet transform
%   ilwt2       - Inverse 2-D lifting wavelet transform
%   liftfilt    - Apply elementary lifting steps on filters
%   liftwave    - Lifting scheme for usual wavelets
%   lsinfo      - Information about lifting schemes
%   lwt         - Lifting wavelet decomposition 1-D
%   lwt2        - Lifting wavelet decomposition 2-D
%   lwtcoef     - Extract or reconstruct 1-D LWT wavelet coefficients
%   lwtcoef2    - Extract or reconstruct 2-D LWT wavelet coefficients
%   wave2lp     - Laurent polynomial associated to a wavelet
%   wavenames   - Wavelet names information
%
% Laurent Polynomial [OBJECT in @laurpoly directory]
%   laurpoly    - Constructor for the class LAURPOLY (Laurent Polynomial)
%
% Laurent Matrix [OBJECT in @laurmat directory]
%   laurmat     - Constructor for the class LAURMAT (Laurent Matrix)
%
% Denoising and Compression for Signals and Images
%   cmddenoise              - Command line interval dependent denoising
%   ddencmp                 - Default values for denoising or compression
%   thselect                - Threshold selection for denoising
%   wbmpen                  - Penalized threshold for wavelet 1-D or 2-D denoising
%   wdcbm                   - Thresholds for wavelet 1-D using Birge-Massart strategy
%   wdcbm2                  - Thresholds for wavelet 2-D using Birge-Massart strategy
%   wdenoise                - Wavelet signal denoising
%   wden                    - Automatic 1-D denoising using wavelets
%   wdencmp                 - Denoising or compression using wavelets
%   wnoise                  - Generate noisy wavelet test data
%   wnoisest                - Estimate noise of 1-D wavelet coefficients
%   wpbmpen                 - Penalized threshold for wavelet packet denoising
%   wpdencmp                - Denoising or compression using wavelet packets
%   wpthcoef                - Wavelet packet coefficients thresholding
%   waveletSignalDenoiser   - Wavelet signal denoiser app
%   wthcoef                 - Wavelet coefficient thresholding 1-D
%   wthcoef2                - Wavelet coefficient thresholding 2-D
%   wthresh                 - Perform soft or hard thresholding
%   wthrmngr                - Threshold settings manager
%
% Other Wavelet Applications
%   dwtleader	- Multifractal 1-D wavelet leader estimates
%   wfbm        - Synthesize fractional Brownian motion
%   wfbmesti    - Estimate fractal index
%   wfusimg     - Fusion of two images
%   wfusmat     - Fusion of two matrices or arrays
%
% Tree Management Utilities
%   allnodes    - Tree nodes
%   cfs2wpt     - Wavelet packet tree construction from coefficients
%   depo2ind    - Node depth-position to node index
%   disp        - Display information of WPTREE object
%   drawtree    - Draw wavelet packet decomposition tree (GUI)
%   dtree       - Constructor for the class DTREE
%   get         - Get tree object field contents
%   ind2depo    - Node index to node depth-position
%   isnode      - True for existing node
%   istnode     - Determine indices of terminal nodes
%   leaves      - Determine terminal nodes
%   nodeasc     - Node ascendants
%   nodedesc    - Node descendants
%   nodejoin    - Recompose node
%   nodepar     - Node parent
%   nodesplt    - Split (decompose) node
%   noleaves    - Determine nonterminal nodes
%   ntnode      - Number of terminal nodes
%   ntree       - Constructor for the class NTREE
%   plot        - Plot tree object
%   read        - Read values in tree object fields
%   readtree    - Read wavelet packet decomposition tree from a figure
%   set         - Set tree object field contents
%   tnodes      - Determine terminal nodes (obsolete - use LEAVES)
%   treedpth    - Tree depth
%   treeord     - Tree order
%   wptree      - Constructor for the class WPTREE
%   wpviewcf    - Plot wavelet packets colored coefficients
%   write       - Write values in tree object fields
%   wtbo        - Constructor for the class WTBO
%   wtreemgr    - NTREE object manager
%
% General Utilities
%   localmax    - Compute local maxima positions   
%   wcodemat    - Extended pseudocolor matrix scaling
%   wextend     - Extend a Vector or a Matrix
%   wkeep       - Keep part of a vector or a matrix
%   wrev        - Flip vector
%   wtbxmngr    - Wavelet Toolbox manager
%
% Other
%   wvarchg     - Find variance change points
%
% Wavelets Information
%   waveinfo        - Information on wavelets
%   waveletfamilies - Wavelet families and family members 
%
% Demonstrations
%   demolift        - Demonstrates Lifting functions in the Wavelet Toolbox  
%
% See also WAVEDEMO

% Last Revision: 16-Oct-2017.
% Copyright 1995-2018 The MathWorks, Inc.



