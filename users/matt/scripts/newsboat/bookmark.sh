#!/bin/sh

url="$1"
title="$2"
description="$3"
feed_title="$4"

buku --nostdin --nc -a "$url" newsboat -c "$description" --title "$title" >/dev/null
