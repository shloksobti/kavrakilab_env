ubuntu_version=$(lsb_release -sr)

if [ $ubuntu_version == 12.04 ]
then
    kavrakilab-install-system yaml-cpp
else
    kavrakilab-install-system libyaml-cpp-dev
fi
