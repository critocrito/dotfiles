#!/bin/sh

# Set up an array with outboxes
sentboxes=( "~/.mail/cryptodrunks/cryptodrunks.Sent/" )

# Run mu on each of them
for dir in "${sentboxes[@]}"
do
    /usr/bin/mu index --nocleanup --maildir="${dir}" --muhome=~/.mu-sent-index
done
