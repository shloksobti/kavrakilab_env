Instructions for pulling in all code related to the manipulation reactive synthesis project:

1. Create and install the kavrakilab-env environment per the kavrakilab wiki page.

2. Pull in all packages by
$ kavrakilab-get install ros-symbolic

3. Build using
$ kavrakilab-make

Execution instructions:
1. Turn on thing1, vicon for thing1 (lower box)

2. ssh into realtime machine. Launch thing1 using
$ one

3. On styx, start moveit (as described https://github.com/KavrakiLab/workspaces/wiki/Running-the-Physical-UR5s)
roslaunch ur5_robotiq85_moveit_config ur5_robotiq85_moveit_planning_execution.launch
roslaunch ur5_robotiq85_moveit_config moveit_rviz.launch config:=true (optional)

4. Start vicon connection (as described https://github.com/KavrakiLab/workspaces/wiki/How-to-Use-the-Vicon-System)
roslaunch vicon_bridge vicon.launch
roslaunch vicon_object_server_server server.launch

5. Start the task monitor and execution module
rosrun reactive task_monitor_and_execution_module [spec_file]

6. Run the reactive strategy
rosrun reactive player_abstraction
rosrun symbolic bddPlayer [domain_file] [problem_file] [output_ltl_file]

Extra notes:
Install Syft from KavLab instead
Install CUDD to ~/install
install moveit_ompl_planning_interface from kavLab submodule
run one of the bottom two lines


rosrun symbolic bddPlayer arch.pddl arch_problem.pddl my_out.ltl
rosrun syft ltlf2fol my_out.ltl NNF > my_out.mona
mona -xw my_out.mona > my_out.dfa
~my_out.dfa

move something on the table

