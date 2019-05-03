# kavrakilab_env
This wiki page describes kavrakilab_env, the package manager that we used to install (ROS) packages and dependencies. Its original implementation
is developed at the Eindhoven University of Technology.

    Credits to tue_env (https://github.com/tue-robotics/tue-env)

## Installation

Git is used for version control and if you have no experience with git you can consider reading
through [this simple guide](http://rogerdudler.github.io/git-guide/). Installing git can be done by
opening a terminal and typing:
```bash
sudo apt-get install git
```

Now you can make sure you clone the kavrakilab_env package manager on to you computer:
```bash
git clone git@github.com:KavrakiLab/kavrakilab_env.git ~/.kavrakilab
```
In case you are using a custom version of kavrakilab_env, do not forget to checkout the corresponding branch (if you don't have a custom branch, skip this step). For instance, the real Fetch uses indigo-devel-moveit-kinetic:
```bash
cd ~/.kavrakilab
git checkout indigo-devel-moveit-kinetic
```
Or you can use melodic-devel for ROS Melodic:
```bash
cd ~/.kavrakilab
git checkout melodic-devel
```
Once you have the package manager you can install ROS and setup the ROS environment by typing the following:
```bash
source ~/.kavrakilab/install
```
If you like to learn about ROS, now is the time to do some [ROS tutorials](http://wiki.ros.org/ROS/Tutorials). 
You can safely skip the first tutorial, since you have ROS installed and configured already.

## Usage

### Installation

With `kavrakilab-get` you can install various targets. Most of the KAVRAKILAB targets are ROS packages, however, it also
support other (3rd party) targets. Both ROS and non-ROS. The list of packages can be seen [here](installer/targets)
or you can show it in your terminal by typing:
```bash
cd ~/.kavrakilab/installer/targets && ls
```

Targets that are a ROS package, by convention, have a name `ros-name_of_the_ros_package`. In order to install a target,
type:
```bash
kavrakilab-get install <TARGET_NAME>
```
For example, to install the ROS package udp_communication, run the following command:
```bash
kavrakilab-get install ros-udp_communication
```
You can also install multiple packages at once:
```bash
kavrakilab-get install ros-emc2_bringup ros_sa4tp_bringup
```
Likewise you can remove targets if you do not need them:
```bash
kavrakilab-get remove ros-emc2_bringup ros_sa4tp_bringup
```

#### How does it work
Let us assume you install ros-emc2_bringup. The package manager first checks for the installation instruction of the corresponding package
as it is given in  `~/.kavrakilab/installer/targets/ros-emc2_bringup/install.yaml`. In this file, it finds to location of the
package (the location of the git repository) and puts it in the appropriate folder on your hard disk: 
`~/ros/indigo/repos/git@ci.kavrakilab.nl:ivs/ros-project-emc2.git/emc2_bringup`. Besides that, it creates a symbolic
link to the latest version of the target in your ROS workspace (`~/ros/indigo/system`) such that your ROS environment
can find the package. Finally, it updates a list of installed targets that it keeps internally.

### Workspaces
As you might have learned from the ROS tutorials, ROS requires at least one catkin workspace to be set. Whenever ROS looks for a package, it checks 
the ROS workspace(s). In case your package is not in your workspace, ROS does not know where to find it (and therefore can not compile or launch it).

At KAVRAKILAB we mainly use two workspace. One workspace, the system workspace, contains all packages installed using the `kavrakilab-get install <package>` command.
The other workspace, referred to as dev workspace, can be used for all packages under development.

### Building
Now that we have packages installed (or developed), we can compile the packages. In case you would like to compile all targets you have installed you can type:
```bash
kavrakilab-make
```

In case you would like to compile one target and its dependencies:
```bash
kavrakilab-make-isolated package_name
```

#### How does it work
The kavrakilab-make command first enters the ROS system workspace that contains all the packages that you have installed. It then
triggers the `catkin build` command that compiles your ROS environment (as explained [here](http://catkin-tools.readthedocs.io/en/latest/verbs/catkin_build.html).
Notice that the system workspace does not contain the actual files. It instead contains symbolic links to the folder at your hard disk that was used to
check out the code. One reason is that this simplifies working with packages from different repositories.

### Developing packages
Note that developments are done in a separate branch of our repository. Make sure you do not work in the master branch. If
you do not know what this means, check any git tutorial, for example [this one](https://www.atlassian.com/git/tutorials/using-branches).

If you are indeed working on the correct branch, you can move any of the installed targets from
your *ROS system* workspace to your *ROS development* workspace. You can do this by simply
typing:
```bash
kavrakilab-dev package_name
```

You will now find the package in your dev workspace. If you would like to compile your development workspace, you type:
```bash
kavrakilab-make-dev
```

In case you would like to compile one target of your development workspace (and its dependencies, only if they are also in
the development repository):
```bash
kavrakilab-make-dev-isolated package_name
```

If you want to clean (remove) one package from your development workspace you type:
```bash
kavrakilab-dev-clean-pkg package_name
```

If you want to clean all your development workspace you type:
```bash
kavrakilab-dev-clean
```


#### How does it work?
The `kavrakilab-make-dev` command works exactly like to `kavrakilab-make` except for the fact that it uses the developement
ROS workspace `~/ros/indigo/dev`. Again, it does not move or copy files but creates a symbolic link to the folder on your hard disk that contains
the actual source code (`ros/indigo/repos/some_repo/some_package`).

### Adding targets

In case you need a target that is not yet available, you can add it to the list of targets.
- First, you make a new branch (we never work in master).
- Then you add a folder with the name of the target to ~/.kavrakilab/installer/targets/.
- Now you add a file named install.yaml that explains the instalation procedure. Examples:

```yaml
- type: ros # Installs a ros package
  source:
    type: git # this one is on a git repository
    url: https://github.com/tue-robotics/ed_navigation.git
- type: ros # Installs a ros package
  source:
    type: git
    url: ssh://tf.kavrakilab.nl:29418/ros
    sub-dir: ed_models # Package in a sub-dir
- type: target # Installs an other target
  name: target2
- type: system # Installs an system target via sudo apt-get install
  name: cowsay
- type: ros # Installs a ros package
  source:
    type: svn # SVN
    url: https://roboticssrv.wtb.tue.nl/svn/ros/trunk/gazebo_map_maker
```
- Optionally, you can add a setup file. Some packages require environment variables to be set, or maybe you would like to define some aliases. 
All of this can be arranged using the optional setup file. Whenever the package is installed, all the 
aliasses and environment variables set within the setup file are added to your terminal. A more
elaborate example can be found in the `ros-ecowin_bringup` folder. Example:

```bash
alias robot-start="roslaunch robot_launch_files start.launch"
alias l=ls
export ENV_VAR=2
```



