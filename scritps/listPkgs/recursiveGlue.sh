# summ up all. that wil be used fore i686 leaves and for final statistics
# note, that this do not honor the complex repos work as listJavaDependentPkg.sh does. But that do nto hurt at all...
dnf list all > all.nvras
cat all.nvras | grep -v "\.noarch" > all-archfull.nvras
cat all.nvras | grep -e "\.noarch" > all-noarch.nvras
cat all.nvras | grep -e "\.i686" > all-multilib.nvras

# find transitive depndencies 
# will skip check on dead packages and subpackages in nvfrsToNames.sh
export SKIP_CHECK=true;

# initial load, all what depends on java, mvn and friends in 
# build or runtime. result is all.jbump
sh listJavaDependentPkgs.sh
cat all.jbump | sh nvfrsToNames.sh >  tier0.names
cp all.jbump all0.names #jsut for case...

for x in `seq 1 10` ; do
  base=$(($x-1))
  echo $x $base
  sh listJavaDependentPkgs.sh tier$base.names
  cat all.jbump | sh nvfrsToNames.sh >  tier$x.names
  cp all.jbump  >  all$x.names # jsut for case...
done
