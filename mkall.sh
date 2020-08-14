
function step 
{
	COMMENT="$*"
        if [ "$STEPMODE" = "true" ]
        then
        	STEPCOUNT=`expr $STEPCOUNT + 1 `
        	if [ $SKIPSTEP = 0 -o $STEPCOUNT -ge $SKIPSTEP ]
        	then 
        		echo "Comment: $COMMENT"
				echo -n "STEPMODE[$STEPCOUNT] - proceed with [ENTER], <number>, x, [qQ] "
				read A
				if [ "$A" = "x" ]
				then
					set -x 
				elif [ "$A" = "q" -o "$A" = "Q" ]
				then 
					echo "Exiting .."
					exit $PASS
				elif [ "$A" = "" ]
				then 
					set +x
				else
					echo $A | grep "[0-9]"
					if [ $? = 0 ] 
					then 
						echo "Skip to step $A"
						SKIPSTEP=$A
					else
						set +x
					fi 
				fi
			else
				$VERBOSE "STEPMODE[$STEPCOUNT] - skipping step"
			fi
        fi
}

# function step variables start
VERBOSE=true
STEPMODE=false
STEPCOUNT=0
SKIPSTEP=0
WAIT=true
PASS=0
export VERBOSE STEPMODE STEPCOUNT SKIPSTEP WAIT PASS
# function step variables end

BASENAME=`basename $0`
DIRNAME=`dirname $0`
LOGFILE=/tmp/${BASENAME}.$1

while getopts  "b:o:s:St:u:V" OPT
do
	case $OPT in
	S)
		STEPMODE=true
		;;
	V)
		VERBOSE=echo 
		;;
	*)
		echo "Usage: $BASENAME [-S (stepmode)][-V (verbose)]"
		;;
	esac
done
shift $(($OPTIND - 1))

cd $DIRNAME
DIRS=`ls -d */`
echo "DIR[$DIRS]"
for COUNTY in $DIRS
do 
	echo "COUNTY[$COUNTY]"
	cd $COUNTY
	for YEAR in 2017 2018
	do
		echo "YEAR[$YEAR]"
		FILES=`ls *$YEAR.csv | grep -v all.$YEAR.csv`
		if [ ! -f all.$YEAR.csv ] 
		then 
			for FILE in $FILES
			do
				echo "FILE[$FILE]"
				HEADER=`head -1 $FILE` 
				if [ -z "$HEADER1" ] 
				then 
					HEADER1=$HEADER
				fi
				if [ "$HEADER1" = "$HEADER" ]
				then 
					cat $FILE >>all.$YEAR.csv
					step "LINENO[$LINENO]"
				else
					echo "HEADER differs from reference HEADER1"
					echo "HEADER[$HEADER]"
					echo "HEADER1[$HEADER1]"
					if [ -z "$HEADER2" ] 
					then	 
						HEADER2=$HEADER
					fi
					if [ "$HEADER2" = "$HEADER" ]
					then 
						cat $FILE >>all2.$YEAR.csv
						step "LINENO[$LINENO]"
					else
						echo "HEADER differs from reference HEADER1 and HEADER2"
						echo "HEADER[$HEADER]"
						echo "HEADER1[$HEADER1]"
						echo "HEADER2[$HEADER2]"
						step "LINENO[$LINENO]"
						exit 1
					fi
				fi
			done
		fi
		unset HEADER1 HEADER2
	done 
	cd ..
done
