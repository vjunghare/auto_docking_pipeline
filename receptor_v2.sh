#!/bin/bash

FILES="$PWD/*.pdb"
# echo $FILES
rm -rf "outputs_all"
mkdir "outputs_all"
for f in $FILES
do
	b=`basename $f .pdb`
	rm -rf $b
	mkdir $b
	echo -e "\nEnzyme Processing- $b \n"
	ba="$b.pdbqt"
	/home/vivek/Downloads/mgltools_x86_64Linux2_1.5.6/bin/pythonsh /home/vivek/Downloads/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py -r $f -o $ba
	mv $ba $b/.
	f_line='receptor='.$ba
	sed '1 s/^/receptor='"$ba"'\n/' config.txt > $b/config.txt
	cp vina_screen_local_v2.sh $b/.
	cp vina $b/.
	cp vina_split $b/.
	cp complex_prep.py $b/.
	cd $b
	mkdir "dock_output"
	source vina_screen_local_v2.sh
	DFH2="dock_output/*.txt"
	for dfi2 in $DFH2
	do
		tr2=`basename $dfi2`
		cp $dfi2 ../outputs_all/"${b}${tr2}"
	done
	DFH="dock_output/*.pdb"
	for dfi in $DFH
	do
		echo $dfi
		tr=`basename $dfi`
		trtxt=`basename $dfi .pdb`."txt"
		bnw=`basename $b em`
		sed '$ d' $f > tempdb.pdb
		cat tempdb.pdb $dfi > ../outputs_all/"${bnw}${tr}"
		rm tempdb.pdb
	done
	cd ..
	mkdir first_complex_pdbs
	cp ./outputs_all/*1.pdb first_complex_pdbs/
done

