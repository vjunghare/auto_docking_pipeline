#!/bin/bash
FILES="*.pdb"
    for f in $FILES
    do
		echo "$f"
		/usr/local/MGLTools-1.5.6/bin/pythonsh /usr/local/MGLTools-1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -l $f
    done
#done
