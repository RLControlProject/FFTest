#!/bin/bash
#SBATCH --job-name=lowBox_Sim_1713930974.7847342
#SBATCH --output log.lowBox
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --time=2-00
#SBATCH --mem=150G
#SBATCH --account=osw

source $HOME/.bash_profile

echo "Working directory is" $SLURM_SUBMIT_DIR
echo "Job name is" $SLURM_JOB_NAME
echo "Job ID is " $SLURM_JOBID
echo "Job took the following nodes (SLURM_NODELIST)" $SLURM_NODELIST
echo "Submit time is" $(squeue -u $USER -o '%30j %20V' | grep -e $SLURM_JOB_NAME | awk '{print $2}')
echo "Starting job at: " $(date)

nodelist=`scontrol show hostname $SLURM_NODELIST`
nodelist=($nodelist)
echo "Formatted list of nodes is: $nodelist"

module purge
module use /nopt/nrel/apps/modules/centos77/modulefiles
module load mkl/2020.1.217
module load comp-intel/2020.1.217

# ********************************** USER INPUT ********************************** #
turbsimbin='/home/rthedin/local/local_openfast_intelCompilers/bin/turbsim'
basepath='/projects/rlfarmcontr/RLControl_Parallel/RLControl/windfarm_v1p0/FFSetup/../FFSim/Sim_1713930974.7847342'

condList=('Cond00_v05.2_PL0.12_TI10')

nSeeds=1
# ******************************************************************************** #

nodeToUse=0
for cond in ${condList[@]}; do
    currNode=${nodelist[$nodeToUse]}
    for((seed=0; seed<$nSeeds; seed++)); do
       dir=$(printf "%s/%s/Seed_%01d" $basepath $cond $seed)
       echo "Submitting $dir/Low.inp in node $currNode"
       srun -n1 -N1 --exclusive --nodelist=$currNode --mem-per-cpu=150000M $turbsimbin $dir/Low.inp > $dir/log.low.seed$seed.txt 2>&1 &
   done
   (( nodeToUse++ ))
done

wait

echo "Ending job at: " $(date)
