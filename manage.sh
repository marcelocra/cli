#!/usr/bin/env sh
#
# manage.sh - Script to manage the project.
#

. $MCRA_BIN/.rc.common
this_file="$(mm_file_path "$0")"
this_file_directory="$(mm_dir_path "$this_file")"



# If this file is not installed, ask the user to install it.


if [ ! -f "$MCRA_BIN/cli" ]; then
    install_this_file() {
        local should_install_this="no"

        echo 'This file is not installed. Install? (symlink this script to ~/bin/cli)'
        read -p 'y/N ' should_install_this

        if [ "$should_install_this" = "y" ]; then
            echo 'Yes! Installing...'
            echo $this_file $MCRA_BIN/cli
            ln -s "$this_file" "$MCRA_BIN/cli" || fatal "Symlink failed. Check output"
            echo 'Done!'
        else
            echo 'Not installing.'
        fi
    }

    install_this_file
fi



# Process command line arguments.


usage() {
    echo "Usage: $0 [commands]"
    echo
    echo 'commands:'
    echo
    echo '- help: show this message'
    echo '- edit: edit this file (alias: e, -e, --edit)'
    echo '- cron: open crontab file'
    echo '- commitlint: setup commit linting with husky and conventional commits'
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help|"")

            usage

            ;;


        e|edit|-e|--edit)

            $EDITOR $this_file

            ;;


        cron)

            crontab -e

            ;;


        fsharp)

            if [ -z "$2" ]; then
                fatal 'Please, provide a name for the project: fsharp <project-name>'
            fi

            echo 'Creating a new fsharp F# project...'
            dotnet new console -lang F#

            echo 'Adding gitignore and fantomas...'
            dotnet new gitignore
            dotnet new tool-manifest
            dotnet tool install fantomas

            echo 'Done!'

            ;;


        commitlint)

            echo 'See full commitlint docs here:'
            echo '  https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional'
            echo

            if [ -f "./package.json" ]; then
                echo 'Folder already contains a package.json file. Skipping npm init.'
            else
                npm init -y
            fi

            echo 'Installing commitlint and husky as development dependencies...'
            npm install --save-dev @commitlint/{cli,config-conventional} husky

            echo 'Creating commitlint config and husky hooks...'
            echo "export default {extends: ['@commitlint/config-conventional']};" > commitlint.config.js
            npx husky init
            echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg

            echo 'Run the following, to test your setup if you already have commited something:'
            echo '  npx commitlint --from HEAD~1 --to HEAD --verbose'
            echo

            ;;


        *)

            fatal "Unknown parameter passed: $1"

            ;;
    esac
    shift
done



# ==============================================================================
# Reference code.
# ==============================================================================



# Copilot generated
# -----------------


# # Posix compliant case statement.
# case "$1" in
#     "install")
#         echo "Installing dependencies..."
#         ;;
#     "start")
#         echo "Starting the project..."
#         ;;
#     "build")
#         echo "Building the project..."
#         ;;
#     "test")
#         echo "Running tests..."
#         ;;
#     *)
#         echo "Usage: $0 {install|start|build|test}"
#         ;;
# esac


# # Parse command line arguments in a posix compliant way.
# # Source: https://stackoverflow.com/a/14203146/1219006
# while [ "$#" -gt 0 ]; do
#     case "$1" in
#         -h|--help) echo "Usage: $0 {install|start|build|test}"; exit 1;;
#         -i|--install) echo install;;
#         -s|--start) echo start;;
#         *) echo "Unknown parameter passed: $1"; exit 1;;
#     esac
#     shift
# done
