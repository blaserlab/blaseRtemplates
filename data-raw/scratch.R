source("install_2.0.R")

# make sure this is set
Sys.getenv("BLASERTEMPLATES_CACHE_ROOT")

# refresh catalogs (including v2)
hash_n_cache()

# try linking a bioc package + exact deps via pak
install_one_package("bioc::GenomicRanges", how="link_from_cache")

# generate/apply a lockstep infra set for your Bioc version
bioc_syncgroup_apply(bioc_version = BiocManager::version())
