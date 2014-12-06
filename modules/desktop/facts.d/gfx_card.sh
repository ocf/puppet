#!/bin/sh -e
if lspci -mm | grep -i 'nvidia corporation' | grep -iq 'vga compatible'; then
	echo "gfx_brand=nvidia"
else
	echo "gfx_brand=intel"
fi
