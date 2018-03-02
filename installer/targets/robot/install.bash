### Make sure remote launching works ###
kavrakilab-install-cp ros-bash-and-run.sh ~/.ros-bash-and-run.sh
chmod +x ~/.ros-bash-and-run.sh

### Allow user to access serial interfaces ###
if ! groups ${USER} | grep -q dialout
  then
    sudo gpasswd --add ${USER} dialout
fi
