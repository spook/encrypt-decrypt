# encrypt-decrypt
Encrypt &amp; decrypt files from the command line.

## Description
These are simple wrapper scripts to make your encryption even easier.
Two scripts are provided: 'encrypt' and 'decrypt'.
Use 'encrypt' to encrypt the contents of files and optionally obfuscate the filename.
Use 'decrypt' to de-obfuscate filenames and recover the contents of the file.

These scripts work on individual files or directories of files.
If given a directory, they will operate on all files in that directory.
With the recurse (-r) option, they will descend into all subdirectories
and do those files too.

When encrypting, use the obfuscate names (-n) option to hide the files
and rename them to random-looking names.  (It's actually a base64
encoding of the filename).

Use the test (-t) option to see what files would be processed, without
actually affecting the files.

Use the verbose (-v) option to see filenames as they're operated upon.

The passphrase may be provided on the command line with the -p option,
but THIS IS DANGEROUS!  Your command history will keep the passphrase
for attackers to find, and process listings on the system will show
this passphrase.  So please don't use it unless you really know what you
are doing.  You have been warned!

## Caution!

This is for casual encryption.  Don't use these scripts for anything serious!
They're just little wrappers around the 'gpg' and 'base64' commands.
If you were serious you'd use asymmetric (public-private) encryption, anyway!

## Synopsys

        $ encrypt path/to/files/
        Passphrase: xxxx
        Re-enter: xxxx
        123 files encrypted

        $ decrypt path/to/files/
        Passphrase: xxxx
        123 files decrypted

## Usage

Get usage with the help (-h or -?) option.

### encrypt Command

        Usage: encrypt [options] FILES...

        Encrypt files with a symmetric key (a passphrase).
        Can optionally obscure the filenames.
        If FILES are omitted, tries to encrypt all the files in the current,
        directory, including hidden files.

        Options:
            -h | -?    Display this usage help
            -n         Obscure filenames
            -p PHRASE  Passphrase - don't use this, it's just for testing!
            -r         Recurse into subdirectories
            -t         Test mode, show what would be done but don't do it"
            -v         Verbose mode; give more output

### decrypt Command

        Usage: decrypt [options] FILES...

        Decrypt files that were encrypted with a symmetric key (a passphrase).
        Will de-obscure filenames if they were obscured.
        If FILES are omitted, it will try to decrypte all files in the current
        directory, including hidden files.

        Options:
            -h | -?    Display this usage help
            -p PHRASE  Passphrase - don't use this, it's just for testing!
            -r         Recurse into subdirectories
            -t         Test mode, show what would be done but don't do it"
            -v         Verbose mode; give more output

## Prerequisites

When the scripts run they check their prerequisites and will complain if any are missing.
These scripts use `gpg` to do the heavy lifting.  You should have it installed; if not do:

        apt install gpg
              or
        yum install gpg

The 'readlink' utility is also used; please install it if needed.
If using -n to obscure filenames, you also need the `base64` tool.
This comes standard with most distros, typically in the `coreutils` package.

## Restrictions

When files are encrypted, the encrypted name is the original name plus a ".gpg" suffix.
Thus the filename length will grow by 4 characters.  If the filename is larger than
the NAME_MAX of the filesystem minus 4, then it will not be encrypted -- since the new
name won't fit. 

On many file systems, NAME_MAX is 255 thus the max filename length for encryption
is 251 characters long.  On the encryptfs file system, NAME_MAX is typically 143
so 139 is the limit for this utility.

Similary, if encrypting with the -n (obfuscate filename) option, the obfuscation 
uses Base64 encoding which adds roughly 33% to the filename length.  Add then
a special prefix that tags the file as obfuscated, and the ".gpg" suffix.
So with obfuscation a good estimate is the largest filename is around 60% of
your file system's NAME_MAX.

Note that if the filename is too long to obfuscate, but less than the maximum for 
encryption, it will still be encrypted.

## Installation

Copy the 'encrypt' and 'decrypt' files to anyplace in your PATH; /usr/local/bin is recommended.
Make them executable and owned by root.  That's it.  So, as root do:

        cp encrypt /usr/local/bin/
        cp decrypt /usr/local/bin/
        chown root.root /usr/local/bin/encrypt
        chown root.root /usr/local/bin/decrypt
        chmod 755 /usr/local/bin/encrypt
        chmod 755 /usr/local/bin/decrypt

## Why?

For too many years I would encrypt & decrypt my files by typing a mini-script
into the command line every time I wanted to do it...

        for f in *; do echo $pwd | gpg --batch ...

or

        for f in *; openssl aes-256-cbc -a -salt -in $f -out ...

yet always in the back of my mind I'd promise myself I'd make this into a script 
so I wouldn't have to type as much each time.  Well, it happened, and these
little scripts are the results.  Enjoy!

