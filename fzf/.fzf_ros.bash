# See: https://github.com/daenny/fzf_ros/blob/master/fzf_ros.bash

_fzf_ros_complete() {
  local cur selected trigger cmd fzf post
  post="$(caller 0 | awk '{print $2}')_post"
  type -t "$post" > /dev/null 2>&1 || post=cat
  #[ "${FZF_TMUX:-1}" != 0 ] && fzf="fzf-tmux -d ${FZF_TMUX_HEIGHT:-40%}" || fzf="fzf"
  fzf="fzf"

  cmd=$(echo "${COMP_WORDS[0]}" | sed 's/[^a-z0-9_=]/_/g')
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  cur="${COMP_WORDS[COMP_CWORD]}"

  selected=$(cat | $fzf $FZF_COMPLETION_OPTS $1 -q "$cur" | $post | tr '\n' ' ')
  selected=${selected% } # Strip trailing space not to repeat "-o nospace"

  printf '\e[5n'
  if [ -n "$selected" ]; then
    COMPREPLY=("$selected")
    return 0
  fi
}

_fzf_ros_complete_dir() {
  local cur selected trigger cmd fzf post
  post="$(caller 0 | awk '{print $2}')_post"
  type -t "$post" > /dev/null 2>&1 || post=cat
  #[ "${FZF_TMUX:-1}" != 0 ] && fzf="fzf-tmux -d ${FZF_TMUX_HEIGHT:-40%}" || fzf="fzf"
  fzf="fzf"

  cmd=$(echo "${COMP_WORDS[0]}" | sed 's/[^a-z0-9_=]/_/g')
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  cur="${COMP_WORDS[COMP_CWORD]}"

  selected=$(cat | $fzf $FZF_COMPLETION_OPTS $1 -q "$cur" | $post | tr '\n' '/')
  selected=${selected%} # Strip trailing space not to repeat "-o nospace"

  printf '\e[5n'
  if [ -n "$selected" ]; then
    COMPREPLY=("$selected")
    return 0
  fi
}


#_fzf_complete_rosmaster() {
#    _fzf_ros_complete '+m' "$@" < <(
#        cat <(cat ~/.ssh/config /etc/ssh/ssh_config 2> /dev/null | \grep -i '^host' | \grep -v '*') \
  #            <(\grep -v '^\s*\(#\|$\)' /etc/hosts | \grep -Fv '0.0.0.0') |
  #            awk '{if (length($2) > 0) {print $2}}' | sort -u
#    )
#}


_fzf_complete_rosmsg() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      show)
        _fzf_ros_complete '+m' "$@" < <(
        rosmsg list 2> /dev/null
        )
    esac
  else
    _roscomplete_rosmsg "$@"
  fi

}


_fzf_complete_rossrv() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      show)
        _fzf_ros_complete '+m' "$@" < <(
        rossrv list 2> /dev/null
        )
    esac
  else
    _roscomplete_rossrv "$@"
  fi
}

_fzf_complete_rosparam() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      get|delete|set)
        _fzf_ros_complete '+m' "$@" < <(
        rosparam list 2> /dev/null
        )
    esac
  else
    _roscomplete_rosparam "$@"
  fi
}

_fzf_complete_roscd() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"

  if [[ $COMP_CWORD == 1 ]]; then
    if [[ "${COMP_WORDS[1]}" == *"/"* ]]; then
      ROS_PACKAGE_PATH=${ROS_WORKSPACE}:${ROS_PACKAGE_PATH} _roscomplete_sub_dir "$@"
    else
      #tput sc
      IFS=" "
      _fzf_ros_complete_dir '+m' "$@" < <(
      ROS_PACKAGE_PATH=${ROS_WORKSPACE}:${ROS_PACKAGE_PATH} _ros_list_locations
      #rospack list-names 2> /dev/null
      )
      #COMPREPLY=${COMPREPLY% } # Strip trailing space not to repeat "-o nospace"
      #tput rc
      unset IFS
    fi

  fi
}

_fzf_complete_rosservice() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      uri|type|call)
        _fzf_ros_complete '+m' "$@" < <(
        rosservice list 2> /dev/null
        )
    esac
  else
    _roscomplete_rosservice "$@"
  fi
}

_fzf_complete_rostopic() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      echo|bw|hz|info|pub|type)
        _fzf_ros_complete '+m' "$@" < <(
        rostopic list 2> /dev/null
        )
    esac
  elif [[ $COMP_CWORD == 3 && ${COMP_WORDS[1]} == "pub" ]]; then
    tput sc
    COMPREPLY=$(echo $(rostopic type ${COMP_WORDS[2]}))
    COMPREPLY=${COMPREPLY% } # Strip trailing space not to repeat "-o nospace"
    tput rc
  else
    _roscomplete_rostopic "$@"
  fi
}

_fzf_complete_rosnode() {
  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      kill|info|ping)
        _fzf_ros_complete '-m' "$@" < <(
        rosnode list 2> /dev/null
        )
    esac
  else
    _roscomplete_rosnode "$@"
  fi
}


function _fzf_complete_rosrun {
  local perm i prev_arg
  if [[ `uname` == Darwin ]]; then
    perm="+111"
  else
    perm="/111"
  fi
  rosrun_args=("--prefix" "--debug")

  # rosrun ONLY accepts arguments before the package names; we need to honor this
  local start_arg=1
  # loop through args and skip --prefix, arg to prefix and --debug
  for (( i=1; i < ${#COMP_WORDS[*]}; i++ ))
  do
    arg="${COMP_WORDS[i]}"
    case ${arg} in
      "--prefix" | "-p")
        start_arg=$((start_arg+1))
        ;;
      "--debug" | "-d")
        start_arg=$((start_arg+1))
        ;;
      *)
        if [[ $prev_arg == "--prefix" || $prev_arg == "-p" ]]
        then
          start_arg=$((start_arg+1))
        else
          break
        fi
        ;;
    esac
    prev_arg="${arg}"
  done

  local end_arg=$((${#COMP_WORDS[*]} - 1))
  arg="${COMP_WORDS[COMP_CWORD]}"

  if [[ $start_arg > $end_arg ]]
  then
    # complete command names for --prefix
    COMPREPLY=($(compgen -c -- ${arg}))
  else
    if [[ $start_arg == $end_arg ]]
    then
      # completing first argument; can be --arg or package name
      if [[ ${arg} =~ \-.* ]]; then
        COMPREPLY=($(compgen -W "${rosrun_args[*]}" -- ${arg}))
      else
        _fzf_ros_complete '+m' "$@" < <(
        rospack list-names 2> /dev/null
        )
      fi
    elif [[ $((start_arg+1)) == ${end_arg} ]]
    then
      # completing second argument; node within package
      local pkg="${COMP_WORDS[start_arg]}"
      _roscomplete_find "-type f -perm $perm" "${pkg}" "${arg}"
    else
      # completing remaining arguments; per "normal"
      _roscomplete_search_dir "-type f -perm $perm"
    fi
  fi
}

function _fzf_complete_roslaunch {
  arg="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()
  if [[ ${arg} =~ \-\-.* ]]; then
    COMPREPLY=(${COMPREPLY[@]} $(compgen -W "--files --args --nodes --find-node --child --local --screen --server_uri --run_id --wait --port --core --pid --dump-params --skip-log-check --ros-args" -- ${arg}))
  else
    _roscomplete_search_dir "( -type f -regex .*\.launch$ -o -type f -regex .*\.test$ )"
    if [[ $COMP_CWORD == 1 ]]; then
      _fzf_ros_complete '+m' "$@" < <(
      ls *.launch 2> /dev/null & rospack list-names 2> /dev/null
      )
    fi
    # complete roslaunch arguments for a launch file
    if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
      ROSLAUNCH_COMPLETE=$(which roslaunch-complete)
      if [[ -x ${ROSLAUNCH_COMPLETE} ]]; then
        # Call roslaunch-complete instead of roslaunch to get arg completion
        _roslaunch_args=$(${ROSLAUNCH_COMPLETE} ${COMP_WORDS[@]:1:2} 2> /dev/null)
        # roslaunch-complete should be very silent about
        # errors and return 0 if it produced usable completion.
        if [[ $? == 0 ]]; then
          COMPREPLY=($(compgen -W "${_roslaunch_args}" -- "${arg}") ${COMPREPLY[@]})
          # FIXME maybe leave ${COMPREPLY[@]} out if we completed successfully.
        fi
      fi
    fi
  fi
}

_fzf_complete_ci() {
  _fzf_ros_complete '+m' "$@" < <(
  rospack list-names 2> /dev/null
  )
}

_fzf_complete_rosnodes ()
{
  _fzf_ros_complete '+m' "$@" < <(
  rosnode list 2> /dev/null
  )
}

_fzf_complete_srcpackages ()
{
  IFS=" "
  _fzf_ros_complete '+m' "$@" < <(
  ROS_PACKAGE_PATH=${ROS_WORKSPACE} _ros_list_locations
  #rospack list-names 2> /dev/null
  )
  #COMPREPLY=${COMPREPLY% } # Strip trailing space not to repeat "-o nospace"
  #tput rc
  unset IFS
}


_fzf_complete_rosloggerlevelset ()
{
  local arg opts;
  COMPREPLY=();
  arg="${COMP_WORDS[COMP_CWORD]}";

  if [[ $COMP_CWORD == 1 ]]; then
    _fzf_ros_complete '+m' "$@" < <(
    rosnode list 2> /dev/null
    )
  fi
  if [[ $COMP_CWORD == 2 ]]; then
    opts='debug info warning error fatal';
    COMPREPLY=($(compgen -W "$opts" -- ${arg}))
  fi
}

_fzf_complete_apt_list()
{

  COMPREPLY=()
  arg="${COMP_WORDS[COMP_CWORD]}"
  if [[ $COMP_CWORD == 2 ]]; then
    case ${COMP_WORDS[1]} in
      echo|bw|hz|info|pub|type)
        _fzf_ros_complete '+m' "$@" < <(
        rostopic list 2> /dev/null
        )
    esac
  elif [[ $COMP_CWORD == 3 && ${COMP_WORDS[1]} == "pub" ]]; then
    tput sc
    COMPREPLY=$(echo $(rostopic type ${COMP_WORDS[2]}))
    COMPREPLY=${COMPREPLY% } # Strip trailing space not to repeat "-o nospace"
    tput rc
  else
    _roscomplete_rostopic "$@"
  fi
}

#[ -n "$BASH" ] && complete -F _fzf_complete_rosmaster -o default -o bashdefault rosmaster
#[ -n "$BASH" ] && complete -F _fzf_complete_rosmaster -o default -o bashdefault change_rosmaster_to
[ -n "$BASH" ] && complete -F _fzf_complete_rosmsg -o default -o bashdefault rosmsg
[    -n "$BASH" ] && complete -F _fzf_complete_rossrv -o default -o bashdefault rossrv
[ -n "$BASH" ] && complete -F _fzf_complete_rosservice -o default -o bashdefault rosservice
[ -n "$BASH" ] && complete -F _fzf_complete_rosparam -o default -o bashdefault rosparam
[ -n "$BASH" ] && complete -F _fzf_complete_rostopic -o default -o bashdefault rostopic
[ -n "$BASH" ] && complete -F _fzf_complete_rosrun -o default -o bashdefault rosrun
[ -n "$BASH" ] && complete -F _fzf_complete_roslaunch -o default -o bashdefault roslaunch
[ -n "$BASH" ] && complete -F _fzf_complete_roslaunch -o default -o bashdefault rostmuxlaunch
[ -n "$BASH" ] && complete -F _fzf_complete_rosnode -o default -o bashdefault rosnode
[ -n "$BASH" ] && complete -F _fzf_complete_roscd -o "nospace" -o bashdefault  roscd
[ -n "$BASH" ] && complete -F _fzf_complete_rosloggerlevelset -o default -o bashdefault rosloggersetlevel
# if [ $USE_CATKIN_TOOLS ]; then
#     [ -n "$BASH" ] && complete -F _fzf_complete_srcpackages -o default -o bashdefault catkin_ws_make
#     [ -n "$BASH" ] && complete -F _fzf_complete_srcpackages -o default -o bashdefault catkin_release_make
# fi
