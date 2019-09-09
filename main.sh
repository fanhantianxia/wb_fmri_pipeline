#!/bin/bash
input_dir=$1  # /data
output_dir=$2
combs_project_id=$3

mkdir -p /app_file
cd /app_file
git clone https://github.com/fanhantianxia/GitHub.git /app_file
mkdir /root/matlab_script/
cp /app_file/wb_pipeline_FCD /root/matlab_script/

mkdir -p /file_buf
cd /file_buf
git clone https://github.com/fanhantianxia/wb_pipeline_FCD.git /file_buf


echo 'display Input_file_TreeGraph'
cd /data
tree
cp /data/config.json /file_buf 
sleep 3s

echo 'start to convert,please wait...'
cd /file_buf
python nii2bids.py #-d /data 
sleep 3s

echo 'display BIDS_file_TreeGraph'
cd /data/data_BIDS
tree
sleep 3s

echo 'inspect fmriprep version....'
fmriprep --version
sleep 3s

mkdir /DataBuf 
fmriprep /data/data_BIDS $2 participant -w /DataBuf --no-submm-recon --fs-no-reconall

mkdir /FCD  
find /out/fmriprep -type f -name "*desc-preproc_bold.nii.gz" | xargs cp -t  /FCD
gzip  -d  /FCD/*_bold.nii.gz

#在/FCD里添加config.json和fmriprep2FCD.py
cp /file_buf/config.json /FCD
cp /file_buf/fmriprep2FCD.py /FCD
cd /FCD
python fmriprep2FCD.py  #需要修改一下程序内部路径

chmod 777 -R /root/matlab_script/
mkdir /out/FCD  #FCD输出文件夹0
/root/matlab_script/wb_pipeline_FCD /FCD/FCD_Input /out/FCD /file_buf/brain_mask.nii 0.6 2

echo 'END'
