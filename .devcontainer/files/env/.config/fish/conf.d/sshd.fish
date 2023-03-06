if status is-interactive
    # Commands to run in interactive sessions can go here
    set PIDOF (/usr/bin/pidof sshd)
    set RETVAL $status

    # Start sshd if it's not running
    if test "$RETVAL" -eq 1
        source (/usr/bin/sudo /usr/sbin/sshd -D -o ListenAddress=0.0.0.0 &)
    end
end
