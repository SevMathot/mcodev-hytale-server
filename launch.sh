#!/bin/bash

# ====   Copyright 2026, mCoDev Systems, All rights reserved.   ====
# =  Purpose:    Calls tokens.sh and then launches the game server.
# =  Reference:  
# =  Author:     Steve (Sev) Mathot, mCoDev Systems. (www.mcodev.net)
# =  License:    mCoDev Systems General Public License (MIT)
# =  Usage:      ./launch.sh
# =  Output:     
# ==================================================================

source ./tokens.sh

if [ $? -ne 0 ]; then
    echo "Unable to fetch tokens."
    exit 1
fi

./start.sh "$@"
