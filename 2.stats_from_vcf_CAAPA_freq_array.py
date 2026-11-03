import calc_stats_for_swifr_revised
import os
import sys

folder = sys.argv[1]
file = sys.argv[2]
start = sys.argv[3]
end = sys.argv[4]
samplesize = int(sys.argv[5])
freq1 = sys.argv[6]
out = sys.argv[7]
array_num = sys.argv[8]
last = sys.argv[9]

N = 120000 # buffer for 100Kb stats calculation window
if int(array_num) > 1 and int(array_num) < int(last): #not first or last chunk then regular window + 60 kb surrounding each side
	start_ov = int(start) - N//2
	end_ov = int(end) + N//2
elif int(array_num) == 1: #first chunk then only 60 kb surrounding right side
	start_ov = int(start)
	end_ov = int(end) + N//2
elif int(array_num) == int(last): #last chunk then only 60 kb surrounding left side
	start_ov = int(start) - N//2
	end_ov = int(end)

#make sure VCF exists
for f in os.listdir(folder):
    file_name = os.path.join(folder, f)
    if os.path.isfile(file_name) and os.path.basename(file_name) == file:
        print(file_name)
        vcf = calc_stats_for_swifr_revised.VCF(file_name, n=samplesize) #create vcf object
        stat_matrix, snps, pos = vcf.create_stat(N=int(N), target_freq=(float(freq1),0.99), target_list=None, target_range=(start_ov,end_ov), scale=False, pca=False, output_name=out) #call create_stat and store in 3 variables