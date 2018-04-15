if [ ! -d $KAVRAKILAB_SYSTEM_DIR/src/moveit ]
then
    kavrakilab-install-target ros-moveit
    kavrakilab-install-target ros-moveit_msgs
    kavrakilab-install-target ros-moveit_resources
fi

