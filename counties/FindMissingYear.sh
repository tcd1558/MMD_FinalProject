CSVS=`ls *2018*.csv | grep -v all`
echo "Proceed?"
read A
for CSV in $CSVS
do 
	ls  $CSV
	CSV7=`echo $CSV | sed -e 's/2018/2017/g' `
	ls $CSV7
	echo 
	echo "Proceed?"
	read A
done
