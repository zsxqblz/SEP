import numpy as np
from tqdm import tqdm
import os.path
import sys

id_start = int(sys.argv[1])
for coor in ["scoor","pcoor","ncoor"]:
    file_name = "data/240922/240922_d"

    job_arr_start = 0
    job_arr_end = 49
    job_arr_step = 1
    job_arr_l = np.arange(job_arr_start,job_arr_end+1,job_arr_step)

    cnt = 0

    for job_id in tqdm(job_arr_l):
        job_name = file_name + str(id_start + 1 + job_id) + "_" + coor
        if os.path.isfile(job_name+"_scanx.csv") == False:
            print(job_id)
            continue

        if cnt == 0:
            x_l = np.loadtxt(job_name+"_scanx.csv",skiprows=1,delimiter=",")
            y_l = np.loadtxt(job_name+"_scany.csv",skiprows=1,delimiter=",")
            z_l = np.loadtxt(job_name+"_scanz.csv",skiprows=1,delimiter=",")
            data_raw =  np.loadtxt(job_name+"_data.csv",skiprows=1,delimiter=",")
            x_length = len(x_l)
            y_length = len(y_l)
            z_length = len(z_l)
            data_ave_l = data_raw.reshape((x_length,y_length,z_length),order='F')
            # data_ave_l = data_raw[:,0].reshape((z_length,y_length,x_length))
            # data_std_l = data_raw[:,1].reshape((z_length,y_length,x_length))

        else:
            data_raw =  np.loadtxt(job_name+"_data.csv",skiprows=1,delimiter=",")
            data_ave_l = data_ave_l + data_raw.reshape((x_length,y_length,z_length),order='F')
            # data_ave_l = data_ave_l + data_raw[:,0].reshape((z_length,y_length,x_length))
            # data_std_l = data_std_l + data_raw[:,1].reshape((z_length,y_length,x_length))

        cnt = cnt + 1

    data_ave_l = data_ave_l / cnt
    # data_std_l = data_std_l / cnt

    print(cnt)

    np.savez(file_name + str(id_start) + "_" + coor + "_pp.npz",
        x_l=x_l,
        y_l=y_l,
        z_l=z_l,
        data_ave_l=data_ave_l,
        # data_std_l=data_std_l
    )