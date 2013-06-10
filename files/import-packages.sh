#!/bin/sh

#Found here: http://www.debian-administration.org/articles/286 and adapted it

INCOMING=$(dirname $1)

#
# Make sure we're in the apt/ directory
#
cd $INCOMING
cd ..

#
#  See if we found any new packages
#
found=0
for i in $INCOMING/*.changes; do
  if [ -e $i ]; then
    found=`expr $found + 1`
  fi
done


#
#  If we found none then exit
#
if [ "$found" -lt 1 ]; then
   exit
fi


#
#  Now import each new package that we *did* find
#
for i in $INCOMING/*.changes; do

  DIST=$(awk '/Distribution/ {print $2}' ${i})
  # Import package to the distribution.
  reprepro -Vb . include ${DIST} $i

  # Delete the referenced files
  sed '1,/Files:/d' $i | sed '/BEGIN PGP SIGNATURE/,$d' \
       | while read MD SIZE SECTION PRIORITY NAME; do
        
      if [ -z "$NAME" ]; then
           continue
      fi

      #
      #  Delete the referenced file
      #
      if [ -f "$INCOMING/$NAME" ]; then
          rm "$INCOMING/$NAME"  || exit 1
      fi
  done

  # Finally delete the .changes file itself.
  rm  $i
done
