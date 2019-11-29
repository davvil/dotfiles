#!/bin/bash

scrolled_by=`echo $KITTY_PIPE_DATA | sed 's/:.*$//'`
nvim "+set nowrap" "+call cursor(line('$')-${scrolled_by}, 1)"
