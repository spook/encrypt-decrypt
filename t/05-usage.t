#!/usr/bin/perl -w
use strict;
use Cwd qw/abs_path/;
use File::Basename;
use Test::More;

plan tests => 8;
my $MYDIR   = dirname(__FILE__);        # Path to this script, which is in t/ usually
my $ENCRYPT = abs_path "$MYDIR/../encrypt";
my $DECRYPT = abs_path "$MYDIR/../decrypt";


my $out;

like qx/$ENCRYPT -h/, qr/Usage/m, "encrypt -h gives usage";
like qx/$ENCRYPT -?/, qr/Usage/m, "encrypt -? gives usage";
like qx/$DECRYPT -h/, qr/Usage/m, "decrypt -h gives usage";
like qx/$DECRYPT -?/, qr/Usage/m, "decrypt -? gives usage";

$out = qx($ENCRYPT -x 2>&1);
like $out, qr/illegal option/m, "encrypt bad option caught";
like $out, qr/Usage/m,          "encrypt bad option gives usage";

$out = qx($DECRYPT -x 2>&1);
like $out, qr/illegal option/m, "decrypt bad option caught";
like $out, qr/Usage/m,          "decrypt bad option gives usage";

exit 0;
