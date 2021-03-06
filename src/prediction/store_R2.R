##############################
# Lauren A. Hannah
# 04/26/16
#
# Purpose: make measures of similarity for representations
##############################

# Folder to search

# gets inputs from arguments 
args = commandArgs(trailingOnly=TRUE)
file_path = args[1]
#file_path ="../results/Reuters/gics50/"
source("topic_generalized_R2.R")

# Initialize
file_vec = vector(mode = 'character', length = 0)
plain_omni_adj = vector(mode = 'numeric', length = 0)
plain_mixed_adj = vector(mode = 'numeric', length = 0)
omni_mixed_adj = vector(mode = 'numeric', length = 0)
plain_omni_gen = vector(mode = 'numeric', length = 0)
plain_mixed_gen = vector(mode = 'numeric', length = 0)
omni_mixed_gen = vector(mode = 'numeric', length = 0)
num_files = vector(mode = 'numeric', length = 0)

# Loop through subfolders
dir_temp = dir(path=file_path,all.files=FALSE,recursive=FALSE)
# Outputs should be something like 
# [1] "CCI" "CTL" "FTR" "WIN"
counter = 1 # for adding stuff to vectors
for (ticker in dir_temp){
	# Read in files
	filename_mixed = sprintf("%s%s/docs_features_doc_topics.csv", file_path,ticker)
	filename_omni = sprintf("%s%s/features_doc_topics.csv", file_path,ticker)
	filename_plain = sprintf("%s%s/plain_docs_doc_topics.csv", file_path,ticker)
	
	# Need to read in file lists for plain docs and omnigraph to align matrices
	files_omni = sprintf("%s%s/features_docs.csv", file_path,ticker)
	files_plain = sprintf("%s%s/plain_docs_docs.csv", file_path,ticker)
	files_mixed = sprintf("%s%s/docs_features_docs.csv", file_path,ticker)
	
	mixed_mat = read.csv(filename_mixed)
	omni_mat = read.csv(filename_omni)
	plain_mat = read.csv(filename_plain)
	
	# Read in file names
	plain_files = read.csv(files_plain, header = T)
	omni_files = read.csv(files_omni, header = T)
	mixed_files = read.csv(files_mixed, header = T)
	# Find intersection between plain, omni; omni, mixed
	# Read in everything as character, split on '/', then split on '.', and match
	plain_files = as.character(plain_files$x)
	omni_files = as.character(omni_files$x)
	mixed_files = as.character(mixed_files$x)
	for (idx in 1:max(length(plain_files), max(max(length(mixed_files), length(omni_files))))){
		if (idx <= length(plain_files)){
			plain_files_temp = strsplit(plain_files[idx],'/')
			plain_files_temp = strsplit(plain_files_temp[[1]][length(plain_files_temp[[1]])], '.', fixed = T)
			plain_files[idx] = plain_files_temp[[1]][1]
		}
		if (idx <= length(mixed_files)){
			mixed_files_temp = strsplit(mixed_files[idx],'/')
			mixed_files_temp = strsplit(mixed_files_temp[[1]][length(mixed_files_temp[[1]])], '.', fixed = T)
			mixed_files[idx] = mixed_files_temp[[1]][1]
		}
		if (idx <= length(omni_files)){
			omni_files_temp = strsplit(omni_files[idx],'/')
			omni_files_temp = strsplit(omni_files_temp[[1]][length(omni_files_temp[[1]])], '.', fixed = T)
			omni_files[idx] = omni_files_temp[[1]][1]
		}
	}
	# Get intersection lists
	inter_plain_omni = intersect(omni_files,plain_files)
	inter_plain_mixed = intersect(plain_files,mixed_files)
	inter_mixed_omni = intersect(mixed_files,omni_files)
	# Get vectors of elements
	idx_plain4omni = is.element(plain_files, inter_plain_omni)
	idx_omni4plain = is.element(omni_files, inter_plain_omni)
	idx_plain4mixed = is.element(plain_files, inter_plain_mixed)
	idx_mixed4plain = is.element(mixed_files, inter_plain_mixed)
	idx_omni4mixed = is.element(omni_files, inter_mixed_omni)
	idx_mixed4omni = is.element(mixed_files, inter_mixed_omni)
	
	
	# Get R2 values
	plain_mixed = topic_generalized_R2(plain_mat[idx_plain4mixed,], mixed_mat[idx_mixed4plain,])
	print(sum(idx_plain4omni))
	print(sum(idx_omni4plain))
	print(dim(plain_mat[idx_plain4omni,]))
	print(dim(omni_mat[idx_omni4plain,]))
	plain_omni = topic_generalized_R2(plain_mat[idx_plain4omni,], omni_mat[idx_omni4plain,])
	omni_mixed = topic_generalized_R2(omni_mat[idx_omni4mixed,], mixed_mat[idx_mixed4omni,])
	
	# Store
	file_vec[counter] = ticker
	plain_omni_adj[counter] = plain_omni$adjusted_R2
	plain_omni_gen[counter] = plain_omni$generalized_R2
	plain_mixed_adj[counter] = plain_mixed$adjusted_R2
	plain_mixed_gen[counter] = plain_mixed$generalized_R2
	omni_mixed_adj[counter] = omni_mixed$adjusted_R2
	omni_mixed_gen[counter] = omni_mixed$generalized_R2
	num_files[counter] = length(plain_files)
	counter = counter + 1
}

# Make into data frame and store
df_R2 = data.frame(file = file_vec, num_files = num_files, plain_omni_adj = plain_omni_adj, plain_omni_gen = plain_omni_gen, plain_mixed_adj = plain_mixed_adj, plain_mixed_gen = plain_mixed_gen, omni_mixed_adj = omni_mixed_adj, omni_mixed_gen = omni_mixed_gen)

filename = sprintf("%s/df_R2.csv", file_path)
write.csv(df_R2, filename, row.names = F)





