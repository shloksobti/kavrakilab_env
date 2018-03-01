export KAVRAKILAB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export KAVRAKILAB_ENV_GIT_REPOSITORY="git@bitbucket.org:juandhv/kavrakilab-env.git"

# Set the ROS_IP if we are on the 192.168.0.* range
if `hostname -I | grep -q 192.168.0.` ; then
    export ROS_IP=`hostname -I | sed 's/.*\(192\.168\.0\.[0-9]\+\).*/\1/'`
fi

# Load tue-env tool
source $KAVRAKILAB_DIR/setup/kavrakilab-env.bash

# ------------------------------------------
# Helper function for checking if all env vars are set
function _kavrakilab-check-env-vars
{
    [ -n "$KAVRAKILAB_DIR" ] && [ -n "$KAVRAKILAB_ENV" ] && [ -n "$KAVRAKILAB_ENV_DIR" ] \
       && [ -n "$KAVRAKILAB_BIN" ] && return 0   
    echo "[kavrakilab] Not all needed environment variables are set."
    return 1
}
export -f _kavrakilab-check-env-vars

if [ -z "$KAVRAKILAB_ENV" ]
then
    if [ ! -f $KAVRAKILAB_DIR/user/config/default_env ]
    then
        # No environment, so all environment specific setup below does not need to be sourced
        return
    fi

    export KAVRAKILAB_ENV=`cat $KAVRAKILAB_DIR/user/config/default_env`

    if [ ! -f $KAVRAKILAB_DIR/user/envs/$KAVRAKILAB_ENV ]
    then
        echo "[kavrakilab] No such environment: '$KAVRAKILAB_ENV'"
        return
    fi
fi

export KAVRAKILAB_ENV_DIR=`cat $KAVRAKILAB_DIR/user/envs/$KAVRAKILAB_ENV`

if [ ! -d $KAVRAKILAB_ENV_DIR ]
then
    echo "[kavrakilab] Environment directory '$KAVRAKILAB_ENV_DIR' (environment '$KAVRAKILAB_ENV') does not exist"
    return 1
fi

# -----------------------------------------

source $KAVRAKILAB_DIR/setup/kavrakilab.bash_functions

if [ -f $KAVRAKILAB_ENV_DIR/.env/setup/user_setup.bash ]
then
    source $KAVRAKILAB_ENV_DIR/.env/setup/user_setup.bash
fi

if [ -f $KAVRAKILAB_ENV_DIR/.env/setup/target_setup.bash ]
then
	source $KAVRAKILAB_ENV_DIR/.env/setup/target_setup.bash
fi

export KAVRAKILAB_BIN=~/.kavrakilab/bin
export PATH=$KAVRAKILAB_BIN:/usr/lib/ccache:$PATH

export KAVRAKILAB_ENV=$KAVRAKILAB_ENV

# Make sure ROS can find cmake modules of non-ROS packages
export CMAKE_PREFIX_PATH=$KAVRAKILAB_ENV_DIR/cmake:$CMAKE_PREFIX_PATH
