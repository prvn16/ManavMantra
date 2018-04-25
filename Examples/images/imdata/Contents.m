% Image Processing Toolbox --- sample images
% To view these images as a group, run the following command:
%   imageBrowser(fullfile(matlabroot, 'toolbox/images/imdata'))
%
% Sample MAT-files.
%   imdemos.mat                     - Images used in demos.
%   pendulum.mat                    - Used by PendulumLengthExample.
%   regioncoordinates.mat           - Used by LabColorSegmentationExample.
%   trees.mat                       - Scanned painting.
%   westconcordpoints.mat           - Used by aerial photo registration example.
%   mristack.mat                    - Used by help example in IMPLAY.
%   cellsequence.mat                - Used by help example in IMPLAY.
%   defaultBRISQUEModel.mat         - Used by brisque NRQA metric
%   defaultNIQEModel.mat            - Used by niqe NRQA metric
%   eSFRdefaultColorReference.mat   - Used by esfrChart test chart based image quality
%   eSFRdefaultGrayReference.mat    - Used by esfrChart test chart based image quality
%   spiralVol.mat                   - Used by BWSKEL help example.
%
% Sample DICOM images.
%   CT-MONO2-16-ankle.dcm
%   DICOMDIR
%   knee1.dcm
%   knee2.dcm
%   US-PAL-8-10x-echo.dcm
%
% Sample DPX images.
%   peppers.dpx
%
% Sample FITS images.
%   solarspectra.fts
%
% Sample HDR images.
%   brainMRI.hdr
%   office.hdr
%
% Sample JPEG images.
%   baby.jpg
%   car1.jpg
%   car2.jpg
%   eSFRTestImage.jpg
%   flamingos.jpg
%   foggyroad.jpg
%   foggysf1.jpg
%   foggysf2.jpg
%   foosball.jpg
%   football.jpg
%   greens.jpg
%   hallway.jpg
%   hands1.jpg
%   hands2.jpg
%   indiancorn.jpg
%   llama.jpg
%   lowlight_1.jpg
%   lowlight_2.jpg
%   micromarket.jpg
%   office_1.jpg
%   office_2.jpg
%   office_3.jpg
%   office_4.jpg
%   office_5.jpg
%   office_6.jpg
%   parkavenue.jpg
%   peacock.jpg
%   sevilla.jpg
%   sherlock.jpg
%   strawberries.jpg
%   trailer.jpg
%   wagon.jpg
%   yellowlily.jpg
%
% Sample PNG images.
%   bag.png
%   blobs.png
%   circles.png
%   circlesBrightDark.png
%   coins.png
%   coloredChips.png
%   concordorthophoto.png
%   concordaerial.png
%   fabric.png
%   gantrycrane.png
%   glass.png
%   hands1-mask.png
%   hestain.png
%   printedtext.png
%   kobi.png
%   liftingbody.png
%   lighthouse.png
%   onion.png
%   pears.png
%   pillsetc.png
%   rice.png
%   riceblurred.png
%   saturn.png
%   snowflakes.png
%   tape.png
%   testpat1.png
%   text.png
%   threads.png
%   tissue.png
%   toyobjects.png
%   toysflash.png
%   toysnoflash.png
%   westconcordorthophoto.png
%   westconcordaerial.png
%   yellowlily-segmented.png
%
% Sample TIFF images.
%   AT3_1m4_01.tif
%   AT3_1m4_02.tif
%   AT3_1m4_03.tif
%   AT3_1m4_04.tif
%   AT3_1m4_05.tif
%   AT3_1m4_06.tif
%   AT3_1m4_07.tif
%   AT3_1m4_08.tif
%   AT3_1m4_09.tif
%   AT3_1m4_10.tif
%   autumn.tif  
%   board.tif
%   cameraman.tif
%   canoe.tif   
%   cell.tif
%   circbw.tif
%   circuit.tif
%   eight.tif
%   foosballraw.tiff
%   forest.tif
%   kids.tif
%   logo.tif
%   m83.tif
%   mandi.tif
%   m83.tif
%   moon.tif
%   mri.tif
%   paper1.tif
%   pout.tif
%   shadow.tif
%   spine.tif
%   tire.tif
%   trees.tif
%   hotcoffee.tif
%
% Sample Landsat images.
%   littlecoriver.lan
%   mississippi.lan
%   montana.lan
%   paris.lan
%   rio.lan
%   tokyo.lan
%
% Sample AVI files.
%   rhinos.avi
%   traffic.avi
%
% Sample Analyze 7.5 images.
%   brainMRI.img
%
% Photo credits
%   board:
%
%     Computer circuit board, courtesy of Alexander V. Panasyuk,
%     Ph.D., Harvard-Smithsonian Center for Astrophysics.
%
%   cameraman:
%
%     Copyright Massachusetts Institute of Technology.  Used with
%     permission.
%
%   car1:
%   car2:
%
%     Vintage cars at the Wigwam Motel in Holbrook, Arizona,
%     courtesy of Bruno Pop-Stefanov, 2013.
%
%   cell:
%   AT3_1m4_01:
%   AT3_1m4_02:
%   AT3_1m4_03:
%   AT3_1m4_04:
%   AT3_1m4_05:
%   AT3_1m4_06:
%   AT3_1m4_07:
%   AT3_1m4_08:
%   AT3_1m4_09:
%   AT3_1m4_10:
%
%     Cancer cells from rat prostates, courtesy of Alan W. Partin, M.D,
%     Ph.D., Johns Hopkins University School of Medicine.
%
%   circuit:
%
%     Micrograph of 16-bit A/D converter circuit, courtesy of Steve
%     Decker and Shujaat Nadeem, MIT, 1993. 
%
%   concordaerial and westconcordaerial:
%
%     Visible color aerial photographs courtesy of mPower3/Emerge.
%
%   concordorthophoto and westconcordorthophoto:
%
%     Orthoregistered photographs courtesy of Massachusetts Executive Office
%     of Environmental Affairs, MassGIS.
%
%   dog00.dcm - dog21.dcm
%
%     Spinal MRI of a dog, courtesy of John Holohan, 2013.
%
%   eSFRTestImage:
%
%     Indoor test chart image courtesy of Kaustav Nandy, 2016.
%
%   flamingos:
%
%     Flamingos in San Diego zoo, courtesy of Vignesh Krishnan, 2017.
%
%   foggyroad:
%
%     Foggy road and forest, courtesy of Jeff Mather, 2016.
%
%   foggysf1:
%
%     View of San Francisco from Twin Peaks, with Buena Vista Park on the
%     right, Alcatraz behind it, and Angel Island in the distance,
%     courtesy of Bruno Pop-Stefanov, 2016.
%
%   foggysf2:
%
%     Golden Gate Bridge from Fort Point in San Francisco, CA,
%     courtesy of Bruno Pop-Stefanov, 2016.
%
%   forest:
%
%     Photograph of Carmanah Ancient Forest, British Columbia, Canada,
%     courtesy of Susan Cohen. 
%
%   gantrycrane:
%
%     Gantry crane used to build a bridge, courtesy of Jeff Mather.
%   
%   hestain:
%
%     Image of tissue stained with hemotoxylin and eosin (H&E) at 40X
%     magnification, courtesy of Alan W. Partin, M.D., Ph.D., Johns Hopkins
%     University School of Medicine.
%
%  indiancorn:
%
%     Indian corn, courtesy of Jeff Mather, 2017.
%
%   knee1 and knee2:
%
%     Magnetic resonance images of a knee, courtesy of Alex Taylor.
%
%   liftingbody:
%
%     Public domain image of M2-F1 lifting body in tow, courtesy of NASA,
%     1964-01-01, Dryden Flight Research Center #E-10962, GRIN database
%     #GPN-2000-000097.
%
%   llama:
%
%     Courtesy of Bruno Pop-Stefanov, 2017.
%
%   lowlight_1:
%
%     Notre-Dame Cathedral Basilica in Ottawa, Ontario, Canada, courtesy of
%     Jeff Mather, 2016.
%
%   lowlight_2:
%
%     Porte Saint-Jean in Quebec City, Quebec, Canada, courtesy of Jeff
%     Mather, 2015.
%
%   mandi:
%
%     Bayer pattern-encoded image taken by a camera with a sensor
%     alignment of 'bggr', courtesy of Jeremy Barry.
%
%   m83:
%
%     M83 spiral galaxy astronomical image courtesy of Anglo-Australian
%     Observatory, photography by David Malin. 
%
%   moon:
%
%     Copyright Michael Myers.  Used with permission.
%
%   parkavenue:
%   
%     Park Avenue trail in Arches National Park, Utah, Courtesy of Jeff
%     Mather, 2017.
%
%   peacock:
%   
%     Peacock in Melbourne zoo, Courtesy of Vignesh Krishnan, 2017.
%
%   pears:
%
%     Copyright Corel.  Used with permission.
%
%   sevilla:
%   
%     Alcazar in Sevilla, Courtesy of Vignesh Krishnan, 2017.
%
%   sherlock:
%   
%     Sherlock the golden retriever, Courtesy of Bert Jiang, 2017.
%
%   strawberries:
%
%     Courtesy of Bruno Pop-Stefanov, 2017.
%
%   tissue:
%
%     Cytokeratin CAM 5.2 stain of human prostate tissue, courtesy of 
%     Alan W. Partin, M.D, Ph.D., Johns Hopkins University School
%     of Medicine.
%
%   trailer:
%
%     Abandoned trailer near Bagdad Cafe in the Mojave Desert of
%     California, courtesy of Bruno Pop-Stefanov, 2006.
%
%   trees:
%
%     Trees with a View, watercolor and ink on paper, copyright Susan
%     Cohen.  Used with permission. 
%
%   LAN files:
%
%     Permission to use Landsat TM data sets provided by Space Imaging,
%     LLC, Denver, Colorado.
%
%   saturn:
%
%     Public domain image courtesy of NASA, Voyager 2 image, 1981-08-24, 
%     NASA catalog #PIA01364
%
%   solarspectra:
%
%     Solar spectra image courtesy of Ann Walker, Boston University.
%
%   wagon:
%
%     Courtesy of Jeff Mather, 2017.
%
% See also COLORSPACES, IMAGES, IMAGESLIB, IMUITOOLS, IPTFORMATS, IPTUTILS.

%   Copyright 2013-2017 The MathWorks, Inc. 
