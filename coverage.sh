#!/bin/sh

rm -rf cover_db 2>/dev/null
make realclean 1>/dev/null 2>&1
perl Makefile.PL 1>/dev/null 2>&1
HARNESS_PERL_SWITCHES=-MDevel::Cover=+ignore,inc make test
cover

