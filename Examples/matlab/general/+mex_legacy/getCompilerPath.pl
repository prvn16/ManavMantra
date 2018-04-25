#   getCompilerPath.pl is a tool used by mex.getCompilerConfigurations.
#
#   Copyright 2007-2010 The MathWorks, Inc.
#   $Revision: 1.1.8.1 $  $Date: 2013/07/23 01:17:22 $#
#

my $storageLocation;
my $outputType;

BEGIN{
use Getopt::Long;
# Parse inputs
GetOptions('matlabroot=s'       => \$MATLAB,
           'storageLocation=s'  => \$storageLocation,
           'outputType=s'       => \$outputType);
push(@INC, $MATLAB . "/bin" );
}

require 5.008_008;
use strict;
use mexsetup;
use File::Basename;

# Reorganize storage location into something that callstpfile understands
$storageLocation =~ s|\.bat|\.stp|;
my ($storageLocationName, $storageLocationPath, $suffix);
($storageLocationName, $storageLocationPath, $suffix) = fileparse( "$storageLocation", qr{\.stp});
my $record = callstpfile($storageLocationPath, $storageLocationName . $suffix);

# Print appropriate return value
if ($outputType eq 'environmentVariable') {
    print($record->{"root_var"});
} else {
    # Locate the root directory of the compiler.
    my $compilerLocateFcn = $record->{"locate"};
    my @compilerLocations = &$compilerLocateFcn;
    my $foundCompilerLocation;
    
    # Locate the compiler's dependency if there is one.
    foreach my $compilerLocation (@compilerLocations) {
        my $dependencyStorageLocationFile = $record->{"linker_optfile_name"};
        if ($dependencyStorageLocationFile) {
            my $dependencyRecord = callstpfile($storageLocationPath, $dependencyStorageLocationFile . ".stp");
            my $dependencyLocateFcn = $dependencyRecord->{"locate"};
            my @foundDependencyLocations = &$dependencyLocateFcn;
            # If any dependency locations are found then the compiler location is
            # valid; no need to look further.  Otherwise, keep looping over 
            # @compilerLocations.
            if (@foundDependencyLocations > 0) {
                $foundCompilerLocation = $compilerLocation;
                last;
            }
        } else {
            # There is no dependency then no need to look further.
            $foundCompilerLocation = $compilerLocation;
            last;
        }
    } 
    # If no valid compiler locations were found then $foundCompilerLocation is undefined.
    print($foundCompilerLocation);
}

exit(1);
