#!/usr/bin/perl -w
use strict;
use Test::More;
plan tests => 24;
my $TESTDIR = "./test-tmp";
BAIL_OUT "Cannot create test directory: $!"
    if !-d $TESTDIR && !mkdir $TESTDIR;

# Determine maximum file name and path lengths
my $NAME_MAX = qx(getconf NAME_MAX $TESTDIR);
my $PATH_MAX = qx(getconf NAME_MAX $TESTDIR);
chomp $NAME_MAX;
chomp $PATH_MAX;
my $BA64_MAX = int($NAME_MAX/4)*3 - length(".:.") - length(".gpg"); # Maximum that can be base64-encoded
diag "Using BA64_MAX = $BA64_MAX";
diag "Using NAME_MAX = $NAME_MAX";
diag "Using PATH_MAX = $PATH_MAX";

# Create test files
mkfile("$TESTDIR/a-normal.tmp");
mkfile("$TESTDIR/A-normal.tmp");    # Uppercase of prior
mkfile("$TESTDIR/bb-normal.tmp");
mkfile("$TESTDIR/ccc-normal.tmp");
mkfile("$TESTDIR/Max-base64: "   . ('U' x ($BA64_MAX-12)));     # OK to encrypt and obscure
mkfile("$TESTDIR/Max-base64+1:"  . ('V' x ($BA64_MAX-12)));     # Can encrypt but not obscure
mkfile("$TESTDIR/Max-base64+2:_" . ('W' x ($BA64_MAX-12)));     # Can encrypt but not obscure
mkfile("$TESTDIR/Max-name: " .     ('X' x ($NAME_MAX-10)));     # Too big to add ".gpg"
mkfile("$TESTDIR/Max-name-3" .     ('Y' x ($NAME_MAX-10-3)));   # Too big to add ".gpg"
mkfile("$TESTDIR/Max-name-4" .     ('Z' x ($NAME_MAX-10-4)));   # Can encrypt but not obscure
mkfile("$TESTDIR/I have blanks in my name.tmp");
mkfile("$TESTDIR/  Blanks  in  front  and at the end  ");
mkfile("$TESTDIR/.hidden-f");
mkfile("$TESTDIR/.hidden-g");

mkdir "$TESTDIR/subdir-a";
mkdir "$TESTDIR/ dir with  blanks  ";
mkdir "$TESTDIR/.hiddendir-c";
mkdir "$TESTDIR/. hidden dir and  blanks  ";


# Cleanup
#rmdir $TESTDIR;
exit 0;


sub mkfile {
    my $name = shift;
    open F, '>', $name
        or die "*** Cannot create '$name': $!";
    print F "This is file '$name'\nEnd of file.\n";
    close F;
}
