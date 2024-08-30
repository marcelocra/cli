# vim:tw=80:ts=4:sw=4:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen
#!/usr/bin/env sh
#
# A script to help manage the project during development.

readonly CMD="${1:-dev}"

case "$CMD" in
    dev)

        echo 'TODO: add commands here to run in development mode'

        ;;

    release)

        echo 'TODO: add commands here to prepare a release'

        ;;

    *)
        cat <<EOF Usage: ./dev.sh [command=dev]

Options:

    dev (default)
        Runs the project in development mode.

    release
        Produces a release.


ERROR: Invalid command: '$CMD'

EOF

        exit 1

        ;;

esac

exit 0

