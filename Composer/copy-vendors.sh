#!/bin/bash
usage()
{
cat << EOF
usage: $0 options

This script allow to push vendors to an other server

OPTIONS:
    -h Host
    -p Path

Sample usage :
	$0 -h login@server -p /var/www/html/projet/site

EOF
}
HOST=""
DEST_FOLDER=""
VENDOR_FOLDER="${PWD}/vendor"
NOW="$(date +"%d-%m-%Y-%H-%M-%S")"
NEW_VENDOR_FOLDER_NAME="vendor_$NOW"
VENDORS_ARCHIVE="vendors.tar.bz2"


while getopts "h:p:" opt; do
  case $opt in
    h)
	HOST="$OPTARG"
      ;;
    p)
	DEST_FOLDER="$OPTARG"
      ;;
    \?)
        usage
        exit
      ;;
  esac
done

if [[ -z $HOST || -z $DEST_FOLDER ]] ; then
	usage
    exit
fi

if [ ! -d $VENDOR_FOLDER ] ; then
	echo "Folder $VENDOR_FOLDER not found."
	exit
fi
cp -R $PWD/vendor $PWD/$NEW_VENDOR_FOLDER_NAME
tar cvjf $VENDORS_ARCHIVE $NEW_VENDOR_FOLDER_NAME
scp $VENDORS_ARCHIVE $HOST:$DEST_FOLDER
ssh -t $HOST "cd $DEST_FOLDER && tar xvjf $VENDORS_ARCHIVE && rm $VENDORS_ARCHIVE && exit"
rm $VENDORS_ARCHIVE
rm -rf $NEW_VENDOR_FOLDER_NAME