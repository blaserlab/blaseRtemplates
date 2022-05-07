binaries <- read.delim("/workspace/rst/renv/cache_binary_pkg_catalog.tsv", sep = "\t")
package <- binaries[which(binaries$package == "blaseRtemplates"),]
version <- package[which(package$modification_time == max(package$modification_time)),]
cache_path <- file.path(version$path, version$package)
project_path <- file.path(.libPaths()[1], version$package)
project_path
cache_path
unlink(project_path, recursive = TRUE)
file.symlink(from = cache_path, to = project_path)
