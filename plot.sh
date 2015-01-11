#!/bin/bash
#$1 = PostScript file to plot. A2 size recommended.

# Copyright (c) 2015 mirage335

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

landscapePStoHPGL() {
	tempRotatedPS="/tmp/rotated-$(cat /proc/sys/kernel/random/uuid).ps"

	pstoedit -rotate 270 "$1" "$tempRotatedPS" > /dev/null 2>&1
	
	xoffset=$(cat "$tempRotatedPS" | grep '^%%BoundingBox:' | cut -d\  -f2)
	yoffset=$(cat "$tempRotatedPS" | grep '^%%BoundingBox:' | cut -d\  -f3)
	
	let "xshift=$yoffset"
	let "xshift-=1"

	let "yshift=$xoffset"
	let "yshift*=-1"
	let "yshift+=1"
	
	pstoedit -dt -f "hpgl: -penplotter -hpgl2" -rotate 270 -yshift $yshift -xshift $xshift "$1" "$2" > /dev/null 2>&1
	
	rm -f "$tempRotatedPS"
}

portraitPStoHPGL() {
	pstoedit -dt -f "hpgl: -penplotter -hpgl2" "$1" "$2" > /dev/null 2>&1
}

PStoHPGL() {
	if grep '%%Orientation: Landscape' PWMController-sys-A2.ps > /dev/null
	then
		landscapePStoHPGL "$1" "$2"
	else
		portraitPStoHPGL "$1" "$2"
	fi
}

PStoPlotter() {
	tempHPGL="/tmp/plotter-$(cat /proc/sys/kernel/random/uuid).hpgl"
	port="/dev/lp0"
	
	PStoHPGL "$1" "$tempHPGL"
	
	cat "tempHPGL" > "$port"
}

#Function inclusion guard.
if [[ "$1" == "" ]]
then
	return
fi

PStoPlotter "$1"