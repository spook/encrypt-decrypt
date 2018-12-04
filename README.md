# encrypt-decrypt
Encrypt &amp; Decrypt Files from the Command Line.
Simple wrapper scripts to make encryption even easier.

## Caution!

This is for casual encryption.  Don't use these scripts for anything serious!
They're just little wrappers around the 'gpg' command.
Plus, if you were serious you'd use asymmetric (public-private) encryption anyway.

## Synopsys

        $ encrypt path/to/files/*
        Passphrase: xxxx
        Re-enter: xxxx
        123 files encrypted

        $ decrypt path/to/files/*
        Passphrase: xxxx
        123 files decrypted


## Prerequisites

These scripts use `gpg` to do the heavy lifting.  You should have it installed; if not do:

        apt install gpg
              or
        yum install gpg


## Installation

Copy the files to anyplace in your PATH, /usr/local/bin is recommended.
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

