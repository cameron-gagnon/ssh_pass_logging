### SSH Password Logging


__Disclaimer__: I know this is a security risk. Any machines this module is
enacted on should have no confidential information on it, and should not be
shared with any other users (at the minimum). Any real authentication should
take place via public-key authorization to completely avoid going through this
specific PAM setup.


# Key change
Many hours were spent with unsuccessful PAM set ups. This is because previous
versions of ssh + PAM allowed changes to be placed in what turns out to be
completely different files.  To set up password logging in a few simple steps,
one can do the following:

__Note__: This was done on an Ubuntu 16.04 instance running on DigitalOcean's
servers. Slight changes in other OS's or versions may cause these exact steps
to fail.

1. Create a build directory. Mine looked like this:
```$ mkdir /usr/build```

2. Clone this repository
```
$ cd /usr/build
$ git clone https://github.com/cameron-gagnon/ssh_pass_logging.git
```

3.
```
$ cd ssh_pass_logging
$ make
```

4.
```
$ vim /etc/pam.d/common-auth
```

Insert the following text into the file between the lines of text that say: `auth [success=1]... pam_unix.so nullok_secure` and `auth requisite pam_deny.so`
```
# custom PAM modules
auth optional pam_storepw.so
```

5. Go back to your build directory and install the file.

```
$ cd /usr/build/ssh_pass_logging
$ make install
```

This will also restart ssh and take into account the new changes.

6. ???

7. Profit


## Output

This will now log output in the form of:
"time <Y-M-D H-M-S> : host = <IP_ADDR> : username = <USERNAME> : password = <PASSWORD>"

to the `/var/log/passwords` file.


__Important Note:__
Only usernames that exist on the system will have data logged to the output. A
more descriptive answer can be found
[here](https://superuser.com/questions/900417/pam-exec-so-doesnt-write-password-to-script-when-expose-authtok-is-enabled),
and can be seen by exploring the `auth-pam.c` file in ssh's source.
This is because of the way sshd + PAM work together. It is in a larger part to
prevent timing attacks against the system. However, if logging passwords for
non-existent users is important, one can build ssh from source and modify the
module to log incorrect passwords before the "fake" password is set. A patch to
do this can be found [here](https://gist.github.com/sjmurdoch/1572229).
Otherwise, the owner of the system can periodically check for other common
usernames in `/var/log/auth.log` and create fake accounts with those usernames
so the full data can be logged.


# Reference/Sources
This work is done based on inspiration from seeing the /var/log/auth.log file.
After some light research, further inspiration came from
[here](https://www.symantec.com/connect/articles/analyzing-malicious-ssh-login-attempts).
The technical work is based on [this](https://silicon-verl.de/home/flo/software/pamcifs.html)
and [this](http://www.adeptus-mechanicus.com/codex/logsshp/logsshp.html).

The Makefile was adapted from [here](https://github.com/yuex/pam-script/blob/master/Makefile).
