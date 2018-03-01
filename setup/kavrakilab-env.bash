# ----------------------------------------------------------------------------------------------------
#                                              KAVRAKILAB-ENV
# ----------------------------------------------------------------------------------------------------

function kavrakilab-env
{
    if [ -z "$1" ]
    then
        echo """kavrakilab-env is a tool for switching between different installation environments.

    Usage: kavrakilab-env COMMAND [ARG1 ARG2 ...]

    Possible commands:

        init           - Initializes new environment
        remove         - Removes an existing enviroment (no data is lost)
        switch         - Switch to a different environment
        config         - Configures current environment
        set-default    - Set default environment
        list           - List all possible environments
        list-current   - Shows current environment
        cd             - Changes directory to environment directory
"""
        return 1
    fi

    cmd=$1
    shift

    # Make sure the correct directories are there
    mkdir -p $KAVRAKILAB_DIR/user/envs

    if [[ $cmd == "init" ]]
    then
        if [ -z "$1" ]
        then
            echo "Usage: kavrakilab-env init NAME [ DIRECTORY ]"
            return 1
        fi

        local dir=$PWD   # default directory is current directory
        [ -z "$2" ] || dir=$2

        # TODO: make dir absolute

        if [ -f $KAVRAKILAB_DIR/user/envs/$1 ]
        then
            echo "[kavrakilab-env] Environment '$1' already exists"
            return 1
        fi

        if [ -d $dir/.env ]
        then
            echo "[kavrakilab-env] Directory '$dir' is already an environment directory."
            return 1
        fi

        echo "$dir" > $KAVRAKILAB_DIR/user/envs/$1
        mkdir -p $dir/.env
    elif [[ $cmd == "remove" ]]
    then
        if [ -z "$1" ]
        then
            echo "Usage: kavrakilab-env remove ENVIRONMENT"
            return 1
        fi

        if [ ! -f $KAVRAKILAB_DIR/user/envs/$1 ]
        then
            echo "[kavrakilab-env] No such environment: '$1'."
            return 1
        fi

        rm $KAVRAKILAB_DIR/user/envs/$1
    elif [[ $cmd == "switch" ]]
    then
        if [ -z "$1" ]
        then
            echo "Usage: kavrakilab-env switch ENVIRONMENT"
            return 1
        fi

        if [ ! -f $KAVRAKILAB_DIR/user/envs/$1 ]
        then
            echo "[kavrakilab-env] No such environment: '$1'."
            return 1
        fi

        export KAVRAKILAB_ENV=$1
        export KAVRAKILAB_ENV_DIR=`cat $KAVRAKILAB_DIR/user/envs/$1`
        
        source ~/.bashrc

    elif [[ $cmd == "set-default" ]]
    then
        if [ -z "$1" ]
        then
            echo "Usage: kavrakilab-env set-default ENVIRONMENT"
            return 1
        fi

        mkdir -p $KAVRAKILAB_DIR/user/config
        echo "$1" > $KAVRAKILAB_DIR/user/config/default_env

    elif [[ $cmd == "config" ]]
    then
        mkdir -p user_setup.bash    
        vim $KAVRAKILAB_ENV_DIR/.env/setup/user_setup.bash

    elif [[ $cmd == "cd" ]]
    then
        local env=$1
        [ -n "$env" ] || env=$KAVRAKILAB_ENV

        local dir=`cat $KAVRAKILAB_DIR/user/envs/$env`
        cd $dir

    elif [[ $cmd == "list" ]]
    then
        [ -d $KAVRAKILAB_DIR/user/envs ] || return 0

        for env in `ls $KAVRAKILAB_DIR/user/envs`
        do
            echo $env
        done
    elif [[ $cmd == "list-current" ]]
    then
        echo $KAVRAKILAB_ENV
    else
        echo "[kavrakilab-env] Unknown command: '$cmd'"
        return 1
    fi
}

# ----------------------------------------------------------------------------------------------------

function _kavrakilab-env
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "init list switch list-current remove cd set-default config" -- $cur) )
    else
        cmd=${COMP_WORDS[1]}
        if [[ $cmd == "switch" ]] || [[ $cmd == "remove" ]] || [[ $cmd == "cd" ]] || [[ $cmd == "set-default" ]]
        then
            if [ $COMP_CWORD -eq 2 ]
            then
                local envs=
                [ -d $KAVRAKILAB_DIR/user/envs ] && envs=`ls $KAVRAKILAB_DIR/user/envs`
                COMPREPLY=( $(compgen -W "$envs" -- $cur) )        
            fi
        fi
    fi
}
complete -F _kavrakilab-env kavrakilab-env