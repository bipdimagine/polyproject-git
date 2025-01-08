import csv
import sys
sys.path.append('/poly-disk/poly-src/Spring/cgi-bin/SPRING_dev/data_prep')
from spring_helper import *
from doublet_detector import *
from collections import defaultdict

import argparse
parser = argparse.ArgumentParser()
#parser.add_argument("-h", "--help", help="Usage : python(2.7) prepare_data.py ")
parser.add_argument("-im", "--matrix", nargs=1, help="Data Input Matrix with Path")
parser.add_argument("-ig", "--gene", nargs=1,  help="Data Input GeneList with Path")
parser.add_argument("-gr", "--group", nargs=1,  help="Data Input Cell Grouping")
parser.add_argument("-o", "--output", nargs=1, help="Data Output Path")
parser.add_argument("-g", "--graph", nargs=1, help="First plot SubDirectory")

args = parser.parse_args()
#quit()

plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = 'Arial'
plt.rc('font', size=14)
plt.rcParams['pdf.fonttype'] = 42



matrix_path = args.matrix[0]
gene_path = args.gene[0]

print matrix_path
print gene_path 

#'/software/distrib/SPRING_dev/SPRING_dev/datasets/GRCh38/'


if os.path.isfile(matrix_path):
    if matrix_path.lower().endswith('.npz'):
        print("Loading NPZ")
        E = scipy.sparse.load_npz(matrix_path)
    elif matrix_path.lower().endswith('.mtx'):
        E = scipy.io.mmread(matrix_path).T.tocsc()
        scipy.sparse.save_npz(matrix_path, E, compressed=True)
    else :
	print("Unsupported format ! npz/mtx only")
	exit()
else:
    print("Matrix file not found.")
    exit()

print E.shape


col=0
if os.path.isfile(gene_path):
    if gene_path.lower().endswith('.tsv'):
	with open(gene_path) as tsvfile:
            reader = csv.reader(tsvfile, delimiter='\t')
	    col = len(next(reader))-1
        print("Loading from .tsv")
        sep = '\t'
	
#        gene_list = np.array(load_genes(gene_path, delimiter='\t', column=col))
        
    elif gene_path.lower().endswith('.csv'):
        print("Loading from .csv")
        with open(gene_path) as tsvfile:
            reader = csv.reader(tsvfile, delimiter=',')
            col = len(next(reader))-1
	sep=','
#        gene_list = np.array(load_genes(gene_path, delimiter=','))
    else :
        print("Unsupported format ! csv/tsv only")
        exit()
else:
    print("Genes file not found.")
    exit()

gene_list = np.array(load_genes(gene_path, delimiter=sep, column=col))


#gene_list = np.array(load_genes(gene_path, delimiter='\t', column=1))
total_counts = E.sum(1).A.squeeze()
E = tot_counts_norm(E)[0]
main_spring_dir = args.output[0]

if not os.path.exists(main_spring_dir):
    os.makedirs(main_spring_dir)
np.savetxt(main_spring_dir + '/genes.txt', gene_list, fmt='%s')
np.savetxt(main_spring_dir + '/total_counts.txt', total_counts)
# save master expression matrices

print 'Saving hdf5 file for fast gene loading...'
save_hdf5_genes(E, gene_list, main_spring_dir + '/counts_norm_sparse_genes.hdf5')

##############
print 'Saving hdf5 file for fast cell loading...'
save_hdf5_cells(E, main_spring_dir + '/counts_norm_sparse_cells.hdf5')

##############
save_sparse_npz(E, main_spring_dir + '/counts_norm.npz', compressed = False)



t0 = time.time()

save_path = main_spring_dir + '/'+ args.graph[0]

out = make_spring_subplot(E, gene_list, save_path, 
                    normalize = False, tot_counts_final = total_counts,
                    min_counts = 3, min_cells = 3, min_vscore_pctl = 85,show_vscore_plot = False, 
                    num_pc = 30, 
                    k_neigh = 4, 
                    num_force_iter = 500)
####                    min_counts = 3, min_cells = 3, min_vscore_pctl = 85,show_vscore_plot = True, 

np.save(save_path + '/cell_filter.npy', np.arange(E.shape[0]))
np.savetxt(save_path + '/cell_filter.txt',  np.arange(E.shape[0]), fmt='%i')

print 'Finished in %i seconds' %(time.time() - t0)



