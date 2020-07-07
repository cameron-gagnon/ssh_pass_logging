# SSH Password Logging


# Disclaimer:
I know this is a security risk. Any machines this module is
enacted on should have no confidential/personal information on it, and should not be
shared with any other users. Really, the machine this work is done on
should only be used for this work and nothing else. Any real authentication should
take place via public-key authentication to completely avoid going through this
specific PAM setup. In fact, you may be unable to log in with username and password
authentication after applying these changes. See issue [#1](/../../issues/1).


# Key changes
Many hours were spent with unsuccessful PAM set ups. This is because previous
versions of ssh + PAM allowed changes to be placed in what turns out to be
completely different files. To set up password logging in a few simple steps,
one can do the following:

__Note: This was done on an Ubuntu 16.04 instance running on DigitalOcean's
servers. Slight changes in other OS's or versions may cause these exact steps
to fail.__

1. Create a build directory. Mine looked like this:
```bash
$ mkdir /usr/build
```

2. Clone this repository

```bash
$ cd /usr/build
$ git clone https://github.com/cameron-gagnon/ssh_pass_logging.git
```

3. Make the pam_storepw.so file
```bash
$ cd ssh_pass_logging
$ make
```

4. Edit the PAM file
```bash
$ vim /etc/pam.d/common-auth
```

Insert the lines prepended with '+'s in between the lines that already exist. **DON'T ACTUALLY INSERT THE '+'s INTO THE FILE, JUST THE TEXT AFTER THEM.**
```bash
auth [success=1 default=ignore] pam_unix.so nullok_secure

+ # custom PAM module
+ auth optional pam_storepw.so

#here's the fallback if no module succeeds
auth requisite pam_deny.so
```

5. Go back to your build directory and install the file.
```bash
$ cd /usr/build/ssh_pass_logging
$ make install
```

This will also restart ssh and reload the new changes.

6. :question::question::question:

7. :fire: :fire: :fire: **Profit** :fire: :fire: :fire:


## Logged Password Output

This will now log output in the form of:

```time <Y-M-D H-M-S> : host = <IP_ADDR> : username = <USERNAME> : password = <PASSWORD>```

to the `/var/log/passwords` file.


## Troubleshooting
Send me a message or create an issue! Also, check to make sure that "UsePAM yes" exists in your /etc/sshd_config file and
that password based authentication is enabled. In my case I use public key authentication by default when setting up a VPS
on DigitalOcean, so PasswordAuthentication is disabled by default. Finally, make sure that `PermitRootLogin` is enabled so
that ssh will allow attempts to log in as the root user.
```bash
$ cat /etc/ssh/sshd_config | grep "UsePAM"
UsePAM yes
$ cat /etc/ssh/sshd_config | grep "PasswordAuthentication"
PasswordAuthentication yes
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication, then enable this but set PasswordAuthentication
$ cat /etc/ssh/sshd_config | grep "PermitRootLogin"
PermitRootLogin yes
# the setting of "PermitRootLogin without-password".
```

### Important Note:
Only usernames that exist on the system will have password data logged to the
output. A more descriptive answer can be found
[here](https://superuser.com/questions/900417/pam-exec-so-doesnt-write-password-to-script-when-expose-authtok-is-enabled),
and can be seen by exploring the `auth-pam.c` file in ssh's source.
This is because of the way sshd + PAM work together. It is in a larger part to
prevent timing attacks against the system. However, if logging passwords for
non-existent users is important, one can build ssh from source and modify the
module to log incorrect passwords before the "fake" password is set. A patch to
do this can be found [here](https://gist.github.com/sjmurdoch/1572229).
Otherwise, the owner of the system can periodically check for other common
usernames in `/var/log/passwords` and create fake accounts with those usernames
so the full data can be logged. __Two scripts to easily create dummy accounts can be
accessed in this repository under `honeypot_user.sh` and `create_initial_users.sh`.__


### Reference/Sources
This work is done based on inspiration from seeing the `/var/log/auth.log` file.
After some light research, further inspiration came from
[here](https://www.symantec.com/connect/articles/analyzing-malicious-ssh-login-attempts).
The technical work is based on [this](https://silicon-verl.de/home/flo/software/pamcifs.html)
and [this](http://www.adeptus-mechanicus.com/codex/logsshp/logsshp.html).
The Makefile was adapted from [here](https://github.com/yuex/pam-script/blob/master/Makefile).
