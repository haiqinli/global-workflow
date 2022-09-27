help([[
Load environment to build fbwndgfs on Orion
]])

prepend_path("MODULEPATH", "/apps/contrib/NCEP/libs/hpc-stack-gfsv16/modulefiles/stack")

load(pathJoin("hpc", os.getenv("hpc_ver")))
load(pathJoin("hpc-intel", os.getenv("hpc_intel_ver")))
load(pathJoin("hpc-impi", os.getenv("hpc_impi_ver")))

load(pathJoin("bacio", os.getenv("bacio_ver")))
load(pathJoin("w3nco", os.getenv("w3nco_ver")))
load(pathJoin("w3emc", os.getenv("w3emc_ver")))
load(pathJoin("ip", os.getenv("ip_ver")))
load(pathJoin("sp", os.getenv("sp_ver")))

setenv("myFC","mpiifort")
