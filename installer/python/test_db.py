#! /usr/bin/python

import kavrakilab_install.db

#print kavrakilab_install.db.all_targets()
print kavrakilab_install.db.get_install_deps("ros-ed")
