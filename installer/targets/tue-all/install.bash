targets=`ls ~/.tue/installer/targets`
for target in $targets
do
    if [[ $target != "tue-all" ]]
    then
        kavrakilab-install-target $target
    fi
done
