#!/bin/bash

# convert the int10h.org font follection into C source files.
# see https://int10h.org/oldschool-pc-fonts/
# see https://github.com/cellularmitosis/libint10h_fonts

set -e -o pipefail
set -x

mkdir -p /tmp/int10h_fonts
cd /tmp/int10h_fonts

if ! test -d "fon - Bm (windows bitmap)" ; then
    if ! test -e oldschool_pc_font_pack_v2.2_FULL.zip ; then
        curl -fLO https://int10h.org/oldschool-pc-fonts/download/oldschool_pc_font_pack_v2.2_FULL.zip
    fi
    unzip oldschool_pc_font_pack_v2.2_FULL.zip
fi
cd "fon - Bm (windows bitmap)"

rm -rf /tmp/libint10h_fonts
mkdir /tmp/libint10h_fonts
cat > /tmp/libint10h_fonts/int10h_fonts.h << EOF
#ifndef _INT10H_FONTS_H_
#define _INT10H_FONTS_H_

/* See https://int10h.org/oldschool-pc-fonts/ */
/* See https://github.com/cellularmitosis/libint10h_fonts */

EOF

for FONfile in *.FON ; do
    echo "processing $FONfile"
    # the overall process is FON -> FNT -> PSF -> C struct value

    # these font names have slashes in them, which breaks fon2fnt.
    if echo $FONfile | grep -s -e '_DOS-V_' -e '_PS-55_' ; then
        echo "skipping broken file"
        continue
    fi

    tmpdir=$(mktemp -d)
    cp "$FONfile" $tmpdir/
    cd $tmpdir

    fon2fnts "$FONfile"
    rm "$FONfile"

    for fntfile in *.fnt ; do
        # drop everything after the first dot, and translate '-' to '_'.
        cvar="$(echo "${FONfile}" | sed -e 's|\..*||' | tr '-' '_')"

        # create the header file.
        cat > "${cvar}.h" << EOF
/* See https://int10h.org/oldschool-pc-fonts/ */
/* See https://github.com/cellularmitosis/libint10h_fonts */

#ifndef _${cvar}_H_
#define _${cvar}_H_

#include <stdint.h>

extern uint8_t ${cvar}[];

#endif
EOF

        # create the .c file.
        cat > "${cvar}.c" << EOF
/* See https://int10h.org/oldschool-pc-fonts/ */
/* See https://github.com/cellularmitosis/libint10h_fonts */

#include "${cvar}.h"

uint8_t ${cvar}[] = {
EOF
        fnt2psf "$fntfile" | psf2inc >> "${cvar}.c"
        echo '};' >> "${cvar}.c"

        mv "${cvar}.h" "${cvar}.c" /tmp/libint10h_fonts/
        echo "#include ${cvar}.h" >> /tmp/libint10h_fonts/int10h_fonts.h
        break # TODO is it possible there could be two fonts in one file?
    done
    cd -
    rm -r $tmpdir
done
echo "#endif" >> /tmp/libint10h_fonts/int10h_fonts.h

# create a trivial makefile.
cat > /tmp/libint10h_fonts/Makefile << EOF
default: clean
	gcc -c *.c
	ar rcs libint10h_fonts.a *.o

clean:
	rm -f *.o libint10h_fonts.a
.PHONY: clean
EOF
