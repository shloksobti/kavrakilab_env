#!/bin/bash

_KAVRAKILAB_CATKIN_DEV_DIR=$KAVRAKILAB_ENV_DIR/dev
_KAVRAKILAB_CATKIN_SYSTEM_DIR=$KAVRAKILAB_ENV_DIR/system
_KAVRAKILAB_REPOS_DIR=$KAVRAKILAB_ENV_DIR/repos

# ----------------------------------------------------------------------------------------------------
#                                        HELPER FUNCTIONS
# ----------------------------------------------------------------------------------------------------

function _list_subdirs
{
    fs=`ls $1`
    for f in $fs
    do
        if [ -d $1/$f ]
        then
            echo $f
        fi
    done
}

# ----------------------------------------------------------------------------------------------------
#                                           KAVRAKILAB-CREATE
# ----------------------------------------------------------------------------------------------------

function kavrakilab-create
{
    if [ -z "$1" ]
    then
        echo "Usage: kavrakilab-create TYPE [ ARG1 ARG2 ... ]"
        return 1
    fi

    creation_type=$1

    # remove the first argument (which contained the creation type)
    shift

    if [ -f $KAVRAKILAB_DIR/create/$creation_type/create.bash ]
    then
        source $KAVRAKILAB_DIR/create/$creation_type/create.bash
    elif [ $KAVRAKILAB_DIR/create/$creation_type/create ]
    then
        $KAVRAKILAB_DIR/create/$creation_type/create $@
    else
        echo "kavrakilab-create: invalid creation type: '$creation_type'."
        return 1
    fi
}

function _kavrakilab-create
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "`_list_subdirs $KAVRAKILAB_DIR/create`" -- $cur) )
    fi
}
complete -F _kavrakilab-create kavrakilab-create

# ----------------------------------------------------------------------------------------------------
#                                            KAVRAKILAB-MAKE
# ----------------------------------------------------------------------------------------------------

function kavrakilab-make
{
    # compile non-ros packages if needed
    if [ -d $KAVRAKILAB_ENV_DIR/pkgs ]
    then
        $KAVRAKILAB_DIR/make/pre-configure.bash
        $KAVRAKILAB_DIR/make/configure.bash
        $KAVRAKILAB_DIR/make/make.bash
        $KAVRAKILAB_DIR/make/post-make.bash
    fi    

    if [ -n "$KAVRAKILAB_ROS_DISTRO" ] && [ -d $_KAVRAKILAB_CATKIN_SYSTEM_DIR ]
    then
        case $(cat $_KAVRAKILAB_CATKIN_SYSTEM_DIR/devel/.built_by) in
		'catkin_make')
			catkin_make --directory $_KAVRAKILAB_CATKIN_SYSTEM_DIR -DCMAKE_BUILD_TYPE=RelWithDebInfo $@
			;;
		'catkin build')
			catkin build --workspace $_KAVRAKILAB_CATKIN_SYSTEM_DIR $@
			;;
		'')
			catkin init --workspace $_KAVRAKILAB_CATKIN_SYSTEM_DIR $@
			catkin build --workspace $_KAVRAKILAB_CATKIN_SYSTEM_DIR $@
			;;
		esac
		source ~/.bashrc
    fi
}

function kavrakilab-make-system
{
	case $(cat $_KAVRAKILAB_CATKIN_SYSTEM_DIR/devel/.built_by) in
	'catkin_make')
		catkin_make --directory $_KAVRAKILAB_CATKIN_SYSTEM_DIR -DCMAKE_BUILD_TYPE=RelWithDebInfo $@
		;;
	'catkin build')
		catkin build --workspace $_KAVRAKILAB_CATKIN_SYSTEM_DIR $@
		;;
	'')
		catkin init --workspace $_KAVRAKILAB_CATKIN_SYSTEM_DIR $@
		catkin build --workspace $_KAVRAKILAB_CATKIN_SYSTEM_DIR $@
		;;
	esac
}

function kavrakilab-make-dev
{
	case $(cat $_KAVRAKILAB_CATKIN_DEV_DIR/devel/.built_by) in
	'catkin_make')
		catkin_make --directory $_KAVRAKILAB_CATKIN_DEV_DIR -DCMAKE_BUILD_TYPE=RelWithDebInfo $@
		;;
	'catkin build')
		catkin build --workspace $_KAVRAKILAB_CATKIN_DEV_DIR $@
		;;
	'')
		catkin init --workspace $_KAVRAKILAB_CATKIN_DEV_DIR $@
		catkin build --workspace $_KAVRAKILAB_CATKIN_DEV_DIR $@
		;;
	esac
	source ~/.bashrc
}

function kavrakilab-make-dev-isolated
{
    catkin_make_isolated --directory $_KAVRAKILAB_CATKIN_DEV_DIR -DCMAKE_BUILD_TYPE=RelWithDebInfo $@
}

# ----------------------------------------------------------------------------------------------------
#                                              KAVRAKILAB-DEV
# ----------------------------------------------------------------------------------------------------

function kavrakilab-dev
{
    if [ -z "$1" ]
    then
        _list_subdirs $_KAVRAKILAB_CATKIN_DEV_DIR/src
        return 0
    fi

    for pkg in $@
    do     
        if [ ! -d $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src/$pkg ]
        then
            echo "[kavrakilab-dev] '$pkg' does not exist in the system workspace."
        elif [ -d $_KAVRAKILAB_CATKIN_DEV_DIR/src/$pkg ]
        then
            echo "[kavrakilab-dev] '$pkg' is already in the dev workspace."
        else
            ln -s $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src/$pkg $_KAVRAKILAB_CATKIN_DEV_DIR/src/$pkg
        fi
    done

    # Call rospack such that the linked directories are indexed
    local tmp=`rospack profile`
}

function kavrakilab-dev-clean
{
    for f in `_list_subdirs $_KAVRAKILAB_CATKIN_DEV_DIR/src`
    do
        # Test if f is a symbolic link
        if [[ -L $_KAVRAKILAB_CATKIN_DEV_DIR/src/$f ]]
        then
            echo "Cleaned '$f'"
            rm $_KAVRAKILAB_CATKIN_DEV_DIR/src/$f
        fi
    done

    rm -rf $_KAVRAKILAB_CATKIN_DEV_DIR/devel/share
    rm -rf $_KAVRAKILAB_CATKIN_DEV_DIR/devel/etc
    rm -rf $_KAVRAKILAB_CATKIN_DEV_DIR/devel/include
    rm -rf $_KAVRAKILAB_CATKIN_DEV_DIR/devel/lib
    rm -rf $_KAVRAKILAB_CATKIN_DEV_DIR/build
}

function _kavrakilab-dev
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    COMPREPLY=( $(compgen -W "`_list_subdirs $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src`" -- $cur) )
}
complete -F _kavrakilab-dev kavrakilab-dev

# ----------------------------------------------------------------------------------------------------
#                                             KAVRAKILAB-STATUS
# ----------------------------------------------------------------------------------------------------

#UNTESTED, Unused
function _kavrakilab_repo-modified
{
    local name=$1
    local pkg_dir=$2

    if [ ! -d $pkg_dir ]
    then
        #echo -e "DBG: Dir $pkg_dir does not exist"
        return 0
    fi

    pushd $pkg_dir > /dev/null
    cd $pkg_dir
    if [ ! -d .git ]; then
        # Not a git, skip!
        #echo -e "DBG: Dir $pkg_dir is not a git dir"
        popd > /dev/null
        return 0
    fi
    git diff-index --quiet HEAD --
    if [ $? -ne 0 ]; then
        echo -e "Package $name has modified files!"
        popd > /dev/null
        return 1
    fi
    popd > /dev/null
    return 0
}

function _kavrakilab-repo-status
{
    local name=$1
    local pkg_dir=$2

    if [ ! -d $pkg_dir ]
    then
        return
    fi

    local status=
    local vctype=

    if [ -d $pkg_dir/.svn ]
    then
        status=`svn status $pkg_dir`
        vctype=svn
    else
        # Try git

        cd $pkg_dir
        res=$(git status . --short --branch 2>&1)
        if [ $? -eq 0 ]
        then
            # Is git
            if echo "$res" | grep -q '\['   # Check if ahead of branch
            then
                status=$res
            else
                status=`git status . --short`
            fi

            local current_branch=`git rev-parse --abbrev-ref HEAD`
            if [ $current_branch != "master" ] && [ $current_branch != "hydro-devel" ] && [ $current_branch != "develop" ] && [ $current_branch != "indigo-devel" ] && [ $current_branch != "jade-devel" ]
            then
                echo -e "\033[1m$name\033[0m is on branch '$current_branch'"
            fi

        fi  

        cd - &> /dev/null
        vctype=git
    #else
    #    show=false
    fi

    if [ -n "$vctype" ]
    then
        if [ -n "$status" ]; then
            echo ""
            echo -e "\033[38;5;1mM  \033[0m($vctype) \033[1m$name\033[0m"
            echo "--------------------------------------------------"
            echo -e "$status"
            echo "--------------------------------------------------"
        fi 
    fi    
}

# ----------------------------------------------------------------------------------------------------

function _kavrakilab-dir-status
{
    [ -d "$1" ] || return

    local fs=`ls $1`
    for f in $fs
    do
        pkg_dir=$1/$f
        _kavrakilab-repo-status $f $pkg_dir        
    done   
}

# ----------------------------------------------------------------------------------------------------

function kavrakilab-status
{
    _kavrakilab-dir-status $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src
    _kavrakilab-dir-status $KAVRAKILAB_ENV_DIR/pkgs
    _kavrakilab-repo-status $KAVRAKILAB_DIR $KAVRAKILAB_DIR
}

# ----------------------------------------------------------------------------------------------------

function kavrakilab-git-status-modified
{
    #echo -e "KAVRAKILAB REPO DIR = $_KAVRAKILAB_REPOS_DIR"
    local repo_root_directories=`ls $_KAVRAKILAB_REPOS_DIR`
    local code=0
    local exit_code=0

    for repo_root in $repo_root_directories
    do
        fs=`ls $_KAVRAKILAB_REPOS_DIR/$repo_root`
        for pkg in $fs
        do
            local full_pkg_dir=$_KAVRAKILAB_REPOS_DIR/$repo_root/$pkg

            if [ -d $full_pkg_dir ]
            then
                _kavrakilab_repo-modified $pkg $full_pkg_dir
                exit_code=$?
                if [ "$exit_code" -ne "0" ]; then
                   let "code+=1"
                fi
            else
                echo -e "DBG: PACKAGE FAILURE dir: $full_pkg_dir"
            fi
        done
    done
    return $code
}

function kavrakilab-git-status
{
    local output=""

    fs=`ls $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src`
    for pkg in $fs
    do
        pkg_dir=$_KAVRAKILAB_CATKIN_SYSTEM_DIR/src/$pkg

        if [ -d $pkg_dir ]
        then
            cd $pkg_dir
            branch=$(git rev-parse --abbrev-ref HEAD 2>&1)
            if [ $? -eq 0 ]
            then
                hash=$(git rev-parse --short HEAD)
                printf "\e[0;36m%-20s\033[0m %-15s %s\n" "$branch" "$hash" "$pkg"
            fi
        fi
    done
}

function kavrakilab-git-status-long
{
    local output=""

    printf "%-40s %-35s %s\n" "Package" "Branch" "Hash"
    fs=`ls $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src`
    for pkg in $fs
    do
        pkg_dir=$_KAVRAKILAB_CATKIN_SYSTEM_DIR/src/$pkg

        if [ -d $pkg_dir ]
        then
            cd $pkg_dir
            branch=$(git rev-parse --abbrev-ref HEAD 2>&1)
            if [ $? -eq 0 ]
            then
                hash=$(git rev-parse HEAD)
                printf "%-40s %-35s %s\n" "$pkg" "$branch" "$hash"
            fi
        fi
    done
    cd $KAVRAKILAB_DIR
    branch=$(git rev-parse --abbrev-ref HEAD 2>&1)
    if [ $? -eq 0 ]
    then
        hash=$(git rev-parse HEAD)
        printf "%-40s %-35s %s\n" "kavrakilab-env" "$branch" "$hash"
    fi
}

# ----------------------------------------------------------------------------------------------------
#                                              KAVRAKILAB-GET
# ----------------------------------------------------------------------------------------------------

function _kavrakilab_depends1
{
    local kavrakilab_dep_dir=$KAVRAKILAB_ENV_DIR/.env/dependencies

    if [ -z "$1" ]
    then
        echo "Usage: kavrakilab-depends PACKAGE"
        return 1
    fi

    if [ ! -f $kavrakilab_dep_dir/$1 ]
    then
        echo "Package '$1' not installed"
        return 1
    fi

    cat $kavrakilab_dep_dir/$1
}

function randid
{
    </dev/urandom tr -dc '0123456789abcdef' | head -c16; echo ""
}

function kavrakilab-get
{
    if [ -z "$1" ]
    then
        echo """kavrakilab-get is a tool for installing and removing packages.

    Usage: kavrakilab-get COMMAND [ARG1 ARG2 ...]

    Possible commands:

        dep            - Shows target dependencies
        install        - Installs a package
        update         - Updates currently installed packages
        remove         - Removes installed package
        list-installed - Lists all manually installed packages

"""
        return 1
    fi

    local kavrakilab_dep_dir=$KAVRAKILAB_ENV_DIR/.env/dependencies
    local kavrakilab_installed_dir=$KAVRAKILAB_ENV_DIR/.env/installed

    cmd=$1
    shift

    if [[ $cmd == "install" ]]
    then        
        if [ -z "$1" ]
        then
            echo "Usage: kavrakilab-get install TARGET [TARGET2 ...]"
            return 1
        fi

        $KAVRAKILAB_DIR/installer/scripts/kavrakilab-install $@
        error_code=$?

        if [ $error_code -eq 0 ]
        then
            # Mark targets as installed
            KAVRAKILAB_INSTALL_INSTALLED_DIR=$KAVRAKILAB_ENV_DIR/.env/installed
            mkdir -p $KAVRAKILAB_INSTALL_INSTALLED_DIR

            for target in $@
            do            
                touch $KAVRAKILAB_INSTALL_INSTALLED_DIR/$1
            done
        fi

        [ $error_code -eq 0 ] && source ~/.bashrc

        return $error_code
    elif [[ $cmd == "update" ]]
    then
        error_code=0
        for target in $@
        do
            if [ ! -f $KAVRAKILAB_ENV_DIR/.env/dependencies/$target ]
            then
                echo "[kavrakilab-get] Package '$target' is not installed."
                error_code=1
            fi
        done

        if [ $error_code -eq 0 ]
        then
            $KAVRAKILAB_DIR/installer/scripts/kavrakilab-install $@
            error_code=$?
            [ $error_code -eq 0 ] && source ~/.bashrc 
        fi
    
        return $error_code       
    elif [[ $cmd == "remove" ]]
    then
        if [ -z "$1" ]
        then
            echo "Usage: kavrakilab-get remove TARGET [TARGET2 ...]"
            return 1
        fi

        error=0
        for target in $@
        do
            if [ ! -f $kavrakilab_installed_dir/$target ]
            then
                echo "[kavrakilab-get] Package '$target' is not installed."
                error=1
            fi
        done        

        if [ $error -gt 0 ];
        then
            echo ""
            echo "[kavrakilab-get] No packages where removed."
            return $error;
        fi

        for target in $@
        do
            rm $kavrakilab_installed_dir/$target 
        done

        echo ""
        if [ -n "$2" ]; then
            echo "The packages were removed from the 'installed list' but still need to be deleted from your workspace."
        else
            echo "The package was removed from the 'installed list' but still needs to be deleted from your workspace."
        fi
    elif [[ $cmd == "list-installed" ]]
    then
        if [[ "$1" == "-a" ]]
        then
            ls $kavrakilab_dep_dir
        else
            ls $KAVRAKILAB_ENV_DIR/.env/installed
        fi
    elif [[ $cmd == "dep" ]]
    then
        $KAVRAKILAB_DIR/installer/scripts/kavrakilab-get-dep $@
    else
        echo "[kavrakilab-get] Unknown command: '$cmd'"
        return 1
    fi
}

function _kavrakilab-get
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "dep install update remove list-installed" -- $cur) )
    else
        cmd=${COMP_WORDS[1]}
        if [[ $cmd == "install" ]]
        then
            COMPREPLY=( $(compgen -W "`ls $KAVRAKILAB_DIR/installer/targets`" -- $cur) )        
        elif [[ $cmd == "dep" ]]
        then
            COMPREPLY=( $(compgen -W "`ls $KAVRAKILAB_ENV_DIR/.env/dependencies`" -- $cur) ) 
        elif [[ $cmd == "update" ]]
        then
            COMPREPLY=( $(compgen -W "`ls $KAVRAKILAB_ENV_DIR/.env/dependencies`" -- $cur) ) 
        elif [[ $cmd == "remove" ]]
        then
            COMPREPLY=( $(compgen -W "`ls $KAVRAKILAB_ENV_DIR/.env/installed`" -- $cur) )  
        else
            COMREPLY=""
        fi
    fi
}
complete -F _kavrakilab-get kavrakilab-get

# ----------------------------------------------------------------------------------------------------
#                                             KAVRAKILAB-CLEAN
# ----------------------------------------------------------------------------------------------------

function kavrakilab-clean
{
    fs=`ls $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src`
    for pkg in $fs
    do
        pkg_dir=$_KAVRAKILAB_CATKIN_SYSTEM_DIR/src/$pkg

        if [ -d $pkg_dir ]
        then
            local memd=$PWD
            cd $pkg_dir
            res=$(git reset . && git clean -fd . && git checkout . 2>&1)
            if [ $? -eq 0 ]                
            then
                echo -e "\033[1m$pkg\033[0m: cleaned"
            fi
            cd $memd
        fi
    done
}

# ----------------------------------------------------------------------------------------------------
#                                             KAVRAKILAB-CHECKOUT
# ----------------------------------------------------------------------------------------------------

function kavrakilab-checkout
{
    if [ -z "$1" ]
    then
        echo """Switches all packages to the given branch, if such a branch exists in that package. Usage:

    kavrakilab-checkout BRANCH-NAME

"""
        return 1
    fi

    local branch=$1

    fs=`ls $_KAVRAKILAB_CATKIN_SYSTEM_DIR/src`
    for pkg in $fs
    do
        pkg_dir=$_KAVRAKILAB_CATKIN_SYSTEM_DIR/src/$pkg

        if [ -d $pkg_dir ]
        then
            local memd=$PWD
            cd $pkg_dir
            res=$(git checkout $branch 2>&1)
            if [ $? -eq 0 ]                
            then
                echo -e "\033[1m$pkg\033[0m: checked-out $branch"
            fi
            cd $memd
        fi
    done
}

# ----------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------

# Change directory to a package
function pcd
{
    if [ -z "$1" ]
    then
        cd $KAVRAKILAB_ENV_DIR/pkgs
        return 
    fi

    if [ ! -d "$KAVRAKILAB_ENV_DIR/pkgs/$1" ]
    then
        echo "[pcd] No such package: '$1'"
        return 1
    fi

    cd $KAVRAKILAB_ENV_DIR/pkgs/$1
}

function _pcd
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ]
    then
        local pkgs=
        [ -d $KAVRAKILAB_ENV_DIR/pkgs ] && pkgs=`_list_subdirs $KAVRAKILAB_ENV_DIR/pkgs`
        COMPREPLY=( $(compgen -W "$pkgs" -- $cur) )
    fi
}
complete -F _pcd pcd

# ----------------------------------------------------------------------------------------------------

source $KAVRAKILAB_DIR/setup/kavrakilab-data.bash

# ----------------------------------------------------------------------------------------------------

function kavrakilab-set-git-remote
{
    local remote=$1
    local server=$2

    if [ -z $2 ]
    then
        echo "Usage: kavrakilab-set-git-remote REMOTE SERVER

For example:

    kavrakilab-set-git-remote origin https://github.com
        "
        return 1
    fi

    local mem_pwd=$PWD

    cd ~/.kavrakilab
    git remote set-url $remote ${server}kavrakilab-robotics/kavrakilab-env

    local fs=`ls $KAVRAKILAB_ENV_DIR/repos/https:/github.com/kavrakilab-robotics`
    for pkg in $fs
    do
        local pkg_dir=$KAVRAKILAB_ENV_DIR/repos/https:/github.com/kavrakilab-robotics/$pkg

        if [ -d $pkg_dir ]
        then
            cd $pkg_dir
            local current_url=`git config --get remote.origin.url`

            if echo "$current_url" | grep -q "kavrakilab-robotics"
            then
                git remote set-url origin ${server}kavrakilab-robotics/$pkg
                echo "Set origin url of '$pkg' to '${server}kavrakilab-robotics/$pkg'"
            fi
        fi
    done

    cd $mem_pwd
}
