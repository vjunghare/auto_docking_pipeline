# Auto docking pipeline

Automated virtual screening with AutoDock Vina. The pipeline docks every ligand in a folder against every receptor in a folder, then converts the poses to PDB and builds receptor–ligand complexes.


## Requirements

1. AutoDock / MGLTools (`prepare_receptor4.py`, `prepare_ligand4.py` and `pdbqt_to_pdb.py` from AutoDockTools)
2. AutoDock Vina (`vina` and `vina_split` are bundled in `vina_files/`)
3. A Bash-compatible Linux environment

## Steps for virtual screening

1. **Populate the ligand folder**
   - `ligand_pop.sh` converts ligand PDB files to PDBQT. Run it inside the folder containing the ligand PDB files, then move the generated `.pdbqt` files into a `lig_pdbqt/` folder.
2. **Prepare receptors and grid**
   - Put each receptor as a `.pdb` file in the working folder.
   - `config.txt` contains the grid parameters (box center and size) and `num_modes`. The `receptor=` line is added automatically for each receptor.
   - `receptor_v2.sh` converts each receptor to PDBQT and creates one folder per receptor.
3. **Run docking**
   - `vina_screen_local_v2.sh` is the main docking run. It is started automatically for each receptor, docks every ligand in `lig_pdbqt/`, and writes the Vina log and output PDBQT for each ligand.
4. **Convert result PDBQT to PDB**
   - `vina_screen_local_v2.sh` splits each result into individual poses with `vina_split` and converts them to PDB with `pdbqt_to_pdb.py`.
5. **Make complexes of ligand and receptor**
   - `receptor_v2.sh` merges each pose PDB with its receptor PDB.

Note: change file names and directories accordingly.

## Running

The scripts expect `vina` and `vina_split` next to them, so copy them out of `vina_files/` into the working folder and make them executable. Arrange the working folder like this:

```text
working_folder/
├── receptor_1.pdb
├── receptor_2.pdb
├── lig_pdbqt/
│   ├── ligand_1.pdbqt
│   └── ligand_2.pdbqt
├── config.txt
├── receptor_v2.sh
├── vina_screen_local_v2.sh
├── vina
└── vina_split
```

Then run:

```bash
cp vina_files/vina vina_files/vina_split .
chmod +x vina vina_split
bash receptor_v2.sh
```

### Docking modes

| Mode | Inputs |
|------|--------|
| Multiple receptors, multiple ligands | Several `.pdb` receptors in the working folder and several ligands in `lig_pdbqt/` |
| Single receptor, multiple ligands | One receptor `.pdb` and several ligands in `lig_pdbqt/` |
| Multiple receptors, single ligand | Several receptor `.pdb` files and one ligand in `lig_pdbqt/` |

All receptors are docked against all ligands.

## Output

| Location | Content |
|----------|---------|
| `<receptor>/dock_output/` | Vina logs, output PDBQT files and pose PDB files for each ligand |
| `outputs_all/` | Vina logs (`<receptor><ligand>.txt`) and receptor–ligand complexes (`<receptor><ligand><pose>.pdb`) |
| `first_complex_pdbs/` | Complexes of the top-ranked poses |

The number of poses per ligand is set by `num_modes` in `config.txt`.

## Notes

- **Grid parameters:** the box center and size in `config.txt` belong to the original target. Set them for your own binding site.
- **Shared grid box:** one `config.txt` is used for every receptor. When docking several receptors, they must be superimposed so that the binding site has the same coordinates.
- **Machine-specific paths:** the scripts call MGLTools through absolute paths (`~/Downloads/mgltools_x86_64Linux2_1.5.6/...`), and `ligand_pop.sh` uses `/usr/local/MGLTools-1.5.6/...`. Edit them for your installation.
- **Ligand preparation:** ligands must be prepared as PDBQT before screening. The pipeline does not create `lig_pdbqt/`.
- **Receptor files:** the last line of each receptor PDB (normally `END`) is removed when the complexes are built, and a trailing `em` in a receptor name is stripped from the complex file names.
- **`complex_prep.py`:** `receptor_v2.sh` tries to copy this file, but it is not included and is not used by the pipeline. The resulting `cp` message can be ignored.
- Docking inputs (receptors and ligands) are not included.

## Related repository

- `docking_figures` — PyMOL and PLIP scripts for generating figures from the docked complexes.
