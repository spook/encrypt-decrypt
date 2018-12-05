#!/usr/bin/perl -w
use strict;
use Cwd qw/abs_path/;
use File::Basename;
use Test::More;

plan tests => 45;
my $TESTDIR = "./test-tmp";
BAIL_OUT "Cannot create test directory: $!"
    if !-d $TESTDIR && !mkdir $TESTDIR;
my $MYDIR = dirname(__FILE__);    # Path to this script, which is in t/
my $ENCRYPT = abs_path "$MYDIR/../encrypt";
my $DECRYPT = abs_path "$MYDIR/../decrypt";

# Determine maximum file name and path lengths
my $NAME_MAX = qx(getconf NAME_MAX $TESTDIR);
my $PATH_MAX = qx(getconf PATH_MAX $TESTDIR);
chomp $NAME_MAX;
chomp $PATH_MAX;
my $BA64_MAX = int($NAME_MAX/4)*3 - length(".:.") - length(".gpg"); # Maximum that can be base64-encoded
diag "Using BA64_MAX = $BA64_MAX";
diag "Using NAME_MAX = $NAME_MAX";
diag "Using PATH_MAX = $PATH_MAX";

diag "Create test files";
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

diag "Encrypt...";
my $out = qx(cd "$TESTDIR";$ENCRYPT -vnp mypassphrase);
is $?, 0, "Exit status";
like $out, qr/^12 files encrypted/m, "Encrypted top-level files";
like $out, qr/cannot encrypt: name too long: Max-name-3/m, "too long to encrypt at max";
like $out, qr/cannot encrypt: name too long: Max-name:/m,  "too long to encrypt at -3";
like $out, qr/cannot obscure\: name too long\: Max-base64\+1\:/m, "can't obscure +1";
like $out, qr/cannot obscure\: name too long\: Max-base64\+2\:/m, "can't obscure +2";
like $out, qr/cannot obscure\: name too long\: Max-name-4/m,      "can't obscure max-4";
like $out, qr/skipdir:  dir with  blanks  $/m,        "skipdir 1";
like $out, qr/skipdir: . hidden dir and  blanks  $/m, "skipdir 2";
like $out, qr/skipdir: .hiddendir-c$/m,               "skipdir 3";
like $out, qr/skipdir: subdir-a$/m,                   "skipdir 4";

my $n = 0;
my $files = qx(ls -1a "$TESTDIR");
foreach my $obscured (qw/
    .:.LmhpZGRlbi1mCg==.gpg
    .:.LmhpZGRlbi1nCg==.gpg
    .:.QS1ub3JtYWwudG1wCg==.gpg
    .:.Y2NjLW5vcm1hbC50bXAK.gpg
    .:.YmItbm9ybWFsLnRtcAo=.gpg
    .:.YS1ub3JtYWwudG1wCg==.gpg
    .:.SSBoYXZlIGJsYW5rcyBpbiBteSBuYW1lLnRtcAo=.gpg
    .:.ICBCbGFua3MgIGluICBmcm9udCAgYW5kIGF0IHRoZSBlbmQgIAo=.gpg
    .:.TWF4LWJhc2U2NDogVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUK.gpg /
) {
    ++$n;
    ok index($files, $obscured) != -1, "file obscured $n";
}

$n = 0;
foreach my $only_encrypt ((
    'Max-base64+1:VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV.gpg',
    'Max-base64+2:_WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW.gpg',
    'Max-name-4ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ.gpg',
    )) {
    ++$n;
    ok index($files, $only_encrypt) != -1, "encrypted, not obscured $n";
}

$n = 0;
foreach my $left_as_is ((
    'Max-name-3YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY',
    'Max-name: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    )) {
    ++$n;
    ok index($files, $left_as_is) != -1, "if cannot encrypt, file left as-is $n";
}

diag "Decrypt...";
$out = qx(cd "$TESTDIR";$DECRYPT -vp mypassphrase);
is $?, 0, "Exit status";
$n = 0;
like $out, qr{^12 files decrypted}m, 
    "Decrypted top-level files";
like $out, qr{^\- skipdir\:  dir with  blanks  }m,
    "skipdir ". (++$n);
like $out, qr{^\- skipdir\: . hidden dir and  blanks  }m,
    "skipdir ". (++$n);
like $out, qr{^\- skipdir\: .hiddendir-c}m,
    "skipdir ". (++$n);
like $out, qr{^\- skipdir\: subdir-a}m,
    "skipdir ". (++$n);
like $out, qr{^\- already\: Max-name-3YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY}m,
    "already ". (++$n);
like $out, qr{^\- already\: Max-name: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}m,
    "already ". (++$n);
like $out, qr{^\+ decrypt\: ./  Blanks  in  front  and at the end  }m,
    "decrypt  ". (++$n);
like $out, qr{^\+ decrypt\: ./.hidden-f}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./.hidden-g}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: Max-base64\+1:VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: Max-base64\+2:_WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: Max-name-4ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./A-normal.tmp}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./I have blanks in my name.tmp}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./Max-base64: UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./ccc-normal.tmp}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./bb-normal.tmp}m,
    "decrypt ". (++$n);
like $out, qr{^\+ decrypt\: ./a-normal.tmp}m,
    "decrypt ". (++$n);

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
