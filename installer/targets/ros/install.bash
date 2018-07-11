if [ -z "$KAVRAKILAB_ROS_DISTRO" ]
then
    echo "[kavrakilab ros install] KAVRAKILAB_ROS_DISTRO was not set"
    return
fi

if [ ! -d /opt/ros/$KAVRAKILAB_ROS_DISTRO ]
then

    sudo apt-get install lsb wget -y
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
    sudo apt-get update

    # Install basic ROS packages. All other packages will be installed using kavrakilab-rosdep
    sudo apt-get install  --assume-yes ros-$KAVRAKILAB_ROS_DISTRO-desktop python-rosinstall python-wstool python-catkin-tools terminator

    sudo rosdep init || true # make sure it always succeeds, even if rosdep init was already called

    rosdep update
    
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt-get update
    		
    if [ $KAVRAKILAB_ROS_DISTRO = "kinetic" ]; then
    	sudo apt-get install  --assume-yes gazebo9
    elif [ $KAVRAKILAB_ROS_DISTRO = "indigo" ]; then
    	sudo apt-get install  --assume-yes gazebo7
    fi
    
fi

source /opt/ros/$KAVRAKILAB_ROS_DISTRO/setup.bash
KAVRAKILAB_SYSTEM_DIR=$KAVRAKILAB_ENV_DIR/system
KAVRAKILAB_DEV_DIR=$KAVRAKILAB_ENV_DIR/dev

if [ ! -f $KAVRAKILAB_SYSTEM_DIR/devel/setup.bash ]
then
    mkdir -p $KAVRAKILAB_SYSTEM_DIR/src
    hash g++ 2> /dev/null || sudo apt-get install --assume-yes g++
    cd $KAVRAKILAB_SYSTEM_DIR
    catkin init
    catkin config -a --cmake-args -DCMAKE_BUILD_TYPE=Release
    catkin build
    touch $KAVRAKILAB_SYSTEM_DIR/devel/.catkin
    source $KAVRAKILAB_SYSTEM_DIR/devel/setup.bash
fi

if [ ! -f $KAVRAKILAB_DEV_DIR/devel/setup.bash ]
then
    mkdir -p $KAVRAKILAB_DEV_DIR/src
    hash g++ 2> /dev/null || sudo apt-get install --assume-yes g++
    cd $KAVRAKILAB_DEV_DIR
    catkin init
    echo "catkin init"
    echo "$KAVRAKILAB_SYSTEM_DIR/devel"
    catkin init
    catkin config -a --cmake-args -DCMAKE_BUILD_TYPE=Release
    catkin build
    touch $KAVRAKILAB_SYSTEM_DIR/devel/.catkin
    source $KAVRAKILAB_DEV_DIR/devel/setup.bash
fi
