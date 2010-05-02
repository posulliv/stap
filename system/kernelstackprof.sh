#!/bin/bash
#
#################################################################################
#
# Purpose:     Samples target process stack using SystemTap
#
# Author:      Padraig O'Sullivan
# Copyright:   (c) http://posulliv.github.com
#
# Usage:       kernelstackprof.sh <PID> [SECONDS] [STACKS]
# 	        
#	        
#################################################################################

DEFAULT_SECONDS=5
DEFAULT_STACKS=20

[ $# -lt 1 ] && echo "  Usage: $0 <PID> [SECONDS] [STACKS]\n" && exit 1
[ -z $2 ] && SECONDS=$DEFAULT_SECONDS || SECONDS=$2
[ -z $3 ] && STACKS=$DEFAULT_STACKS || STACKS=$3
PROCESS=$1

echo
echo "Sampling pid $PROCESS for $SECONDS seconds..."
echo

stap -x $PROCESS -e '
  global time_running
  global backtraces

  probe timer.profile
  {
    if (pid() == target())
    {
      backtraces[backtrace()]++
    }
  }

  probe timer.s(1)
  {
    time_running++
    if (time_running >= '$SECONDS')
    {
      exit();
    }
  }

  probe end
  {
    foreach(stack_trace in backtraces)
    {
      print_stack(stack_trace);
    }
  }
'
