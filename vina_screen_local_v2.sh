#! /bin/bash

FILES1="../lig_pdbqt/*.pdbqt"
for f1 in $FILES1
do
    b1=`basename $f1 .pdbqt`
    echo -e " \n Processing ligand $b1\n"
    mkdir -p $b1
    ./vina --config config.txt --ligand $f1 --out ${b1}/out.pdbqt --log ${b1}/log.txt
    cp ${b1}/log.txt dock_output/$b1.txt
    cp ${b1}/out.pdbqt dock_output/$b1.pdbqt
    ./vina_split --input ${b1}/out.pdbqt --ligand ${b1}/lig
    FILES2="$b1/lig*"
    i=1
    for f2 in $FILES2
    do
        echo -e "\n$f2"
        tmp=`basename $f2 .pdbqt`
        echo -e "\n$tmp"
        /home/vivek/Downloads/mgltools_x86_64Linux2_1.5.6/bin/pythonsh /home/vivek/Downloads/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/pdbqt_to_pdb.py -f $f2 -o temp_out.pdb
        sed "s/${tmp:0:4}/    /" "temp_out.pdb" > temp_out2.pdb
#         cut -c -66 temp_out.pdb > temp_out2.pdb
        sed '1 d' temp_out2.pdb > $tmp.pdb
        rm temp_out.pdb
        rm temp_out2.pdb
        tmp2="$b1$i"
        cp $tmp.pdb dock_output/$tmp2.pdb
        i=$((i+1))
        rm $tmp.pdb
    done
done
