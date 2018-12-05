#!/usr/bin/perl -w
use strict;
use Cwd qw/abs_path/;
use File::Basename;
use Test::More;

plan tests => 8;
my $TESTDIR = "./test-tree";
BAIL_OUT "Cannot create test directory: $!"
    if !-d $TESTDIR && !mkdir $TESTDIR;
my $MYDIR   = dirname(__FILE__);        # Path to this script, which is in t/ usually
my $ENCRYPT = abs_path "$MYDIR/../encrypt";
my $DECRYPT = abs_path "$MYDIR/../decrypt";

diag "Create test files";
mkfile("$TESTDIR/a");
mkfile("$TESTDIR/b.");
mkfile("$TESTDIR/c.c");
mkfile("$TESTDIR/.d");
mkfile("$TESTDIR/...");
mkfile("$TESTDIR/~");
mkdir  "$TESTDIR/sub1";
mkfile("$TESTDIR/sub1/e");
mkfile("$TESTDIR/sub1/f.");
mkfile("$TESTDIR/sub1/g.g");
mkfile("$TESTDIR/sub1/.h");
mkfile("$TESTDIR/sub1/....");
mkfile("$TESTDIR/sub1/.~");
mkdir  "$TESTDIR/sub2";
mkfile("$TESTDIR/sub2/i");
mkfile("$TESTDIR/sub2/j.");
mkfile("$TESTDIR/sub2/k.k");
mkfile("$TESTDIR/sub2/.l");
mkfile("$TESTDIR/sub2/.....");
mkfile("$TESTDIR/sub2/!");
mkdir  "$TESTDIR/sv 3";
mkfile("$TESTDIR/sv 3/m n o");
mkfile("$TESTDIR/sv 3/ p q ");
mkfile("$TESTDIR/sv 3/.. . ");
mkfile("$TESTDIR/sv 3/.. ..");
mkfile("$TESTDIR/sv 3/ !\\~ ");

diag "test finding files...";
my $out;

# non-recursive encrypt/decrypt
$out = qx($ENCRYPT -vp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^6 files encrypted$/m, "encrypt non-recursive found all files";

$out = qx($DECRYPT -vp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^6 files decrypted$/m, "decrypt non-recursive found all files";

# non-recursive encrypt/decrypt with obfuscate
$out = qx($ENCRYPT -vnp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^6 files encrypted$/m, "encrypt with obfuscate non-recursive found all files";

$out = qx($DECRYPT -vp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^6 files decrypted$/m, "decrypt with obfuscate non-recursive found all files";

# recursive encrypt/decrypt
$out = qx($ENCRYPT -vrp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^23 files encrypted$/m, "encrypt recursive found all files";

$out = qx($DECRYPT -vp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^23 files decrypted$/m, "decrypt recursive found all files";

# non-recursive encrypt/decrypt with obfuscate
$out = qx($ENCRYPT -vrnp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^23 files encrypted$/m, "encrypt with obfuscate recursive found all files";

$out = qx($DECRYPT -vp MyPassphrase123 $TESTDIR 2>&1);
like $out, qr/^23 files decrypted$/m, "decrypt with obfuscate recursive found all files";

diag "Cleanup";
qx(rm -fr $TESTDIR);
exit 0;


sub mkfile {
    my $name = shift;
    open F, '>', $name
        or die "*** Cannot create '$name': $!";
    print F "This is file '$name'\nEnd of file.\n";
    close F;
}
