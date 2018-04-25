#!/bin/bash

SOURCE="$1";
DESTINATION="$2";
DESTINATION_BAK="$2$3";

echo_time() {
    echo `date +'%b %e %T:'` "$@"
}

LOG_FILE="/var/mlsedu/log/savesession-safemv.log"

STARTTIME=$(date +%s%3N)

#move file from /tmp to GDS
mv "$SOURCE" "$DESTINATION_BAK"

ENDTIME=$(date +%s%3N)

#Return value of the move. O if successful.
retval=$?

if [ $retval -eq 0 ]; then
    #Rename file in GDS only if transfer from /tmp to GDS was successful
    mv "$DESTINATION_BAK" "$DESTINATION"
    FILESIZE=$(stat -c%s "$DESTINATION")
    echo_time "Moving session file $SOURCE to $DESTINATION is successful. Filesize in bytes: $FILESIZE , Time taken in milliseconds: $((ENDTIME - STARTTIME))" >> ${LOG_FILE}
else
    echo_time "Moving session file $SOURCE to $DESTINATION is unsuccessful. Return code: $retval (Return code 0 if successful)" >> ${LOG_FILE}
fi
