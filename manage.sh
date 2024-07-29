#!/usr/bin/env sh
# vim:fdm=marker:fmr={{{,}}}:fdl=0:fen:
#
# manage.sh - Script to manage the project.
#

# ------------------------------------------------------------------------------
# Load shell helpers, define constans and install this file.
#
# Code below. {{{


# Load shell helpers.
shell_helpers="$HOME/bin/.rc.common"
. $shell_helpers


# Define file constants.
this_file="$(mm_file_path "$0")"
this_file_directory="$(mm_dir_path "$this_file")"


# Check if this file is installed to $MCRA_BIN (default: $HOME/bin) and if not,
# ask the user to install it.
if [ ! -f "$MCRA_BIN/cli" ]; then
    install_this_file() {
        local should_install_this="no"

        echo "This file is not installed. Install? (will symlink this script to $MCRA_BIN/cli)"
        read -p 'y/N ' should_install_this

        if [ "$should_install_this" = "y" ]; then
            echo 'Yes! Installing...'
            if [ ! -d "$MCRA_BIN" ]; then
                mkdir "$MCRA_BIN" || fatal "Failed to create '$MCRA_BIN'"
            fi

            ln -s "$this_file" "$MCRA_BIN/cli" || fatal 'Symlink failed. Check output'

            echo 'Done!'
        else
            echo 'Not installing.'
        fi
    }

    install_this_file
fi


# All commands should be add here, along with description of how to use them.
usage() {
    echo "Usage: $0 [commands]"
    echo
    echo 'commands:'
    echo
    echo '- help: show this message'
    echo '- edit: edit this file (alias: e, -e, --edit)'
    echo '- cron: open crontab file'
    echo '- fsharp: create an F# project preinstalled with Fantomas for source formatting'
    echo '- commitlint: setup commit linting with husky and conventional commits'
    echo '- pandoc: print a pandoc man example command, with groff'
    echo '- common: edit shell helpers'
    echo '- commonp: edit personal shell helpers'
    echo '- dartjs: compile dart to js with level 2 of optimizations'
    echo '- dotnet-publish: create a release self contained binary of a dotnet project'
    echo '- compare-compilations: compare the binary size of hello world programs'
}

# Go to this script folder, mostly useful for checking stuff.
if [ $# -eq 0 ]; then
    cd $this_file_directory
    echo '\nHit ctrl+d to return to the other directory'
    $SHELL
fi


# }}}
# ------------------------------------------------------------------------------



# Parses cli arguments and run the selected commands. Note that all functions
# should be defined inside the command case statement, to avoid mixing one
# command with the other.
main() {
    local editor="${EDITOR:-vi}"

    # Process command line arguments.
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help|"") # {{{

                usage

                ;; # }}}
            e|edit|-e|--edit) # {{{

                (cd $this_file_directory && $editor $this_file)

                ;; # }}}
            cron) # {{{

                crontab -e

                ;; # }}}
            fsharp) # {{{

                if [ -z "$2" ]; then
                    fatal 'Please, provide a name for the project: fsharp <project-name>'
                fi

                echo 'Creating a new fsharp F# project...'
                mkdir "$2" && cd "$2" || fatal "Failed to create directory: $2"
                dotnet new console -lang 'F#' || fatal 'Failed to create a new console program'

                echo 'Adding gitignore and fantomas...'
                dotnet new gitignore || fatal 'Failed to create .gitignore'
                dotnet new tool-manifest || fatal 'Failed to create tool-manifest'
                dotnet tool install fantomas || fatal 'Failed to install fantomas to project'

                echo 'Done!'
                return 0

                ;; # }}}
            commitlint) # {{{

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

                ;; # }}}
            pandoc) # {{{

                mm_trim '
                    To create a manpage, check out the code below or follow the
                    full tutorial here:

                        https://gpanders.com/blog/write-your-own-man-pages/

                    pandoc --standalone \
                        --from markdown \
                        --to man \
                        --metadata title="pandoc example" \
                        --metadata author="marcelo" \
                        --metadata section="the section name" \
                        --metadata date="$(date +%F_%T -r stuff.md)" \
                        stuff.md | groff -T utf8 -man | nvim "+Man!"
                ' 12

                ;; # }}}
            common) # {{{

                (cd "$(mm_dir_path $shell_helpers)" && $editor $shell_helpers)

                ;; # }}}
            commonp) # {{{

                local filename="$MCRA_BIN/commonp.sh"
                (cd "$(mm_dir_path $filename)" && $editor $filename)

                ;; # }}}
            dart) # {{{

                local filename="${3:-main}"

                case "$2" in

                    help|-h|--help)

                        mm_trim '
                            Usage:
                                cli dart [options, default=exe] [filename, default=main, .dart is implied]

                            Options:
                                - exe: dart compile exe
                                - js: dart compile js: default optimizations
                                - jsopt: dart compile js -O2: level 2 optimizations, which are still safe, but smaller
                        ' 24

                        return 1

                        ;;

                    js)

                        dart compile js -o $filename.js $filename.dart

                        ;;


                    jsopt)

                        dart compile js ${3:--O2} -o $filename.js $filename.dart

                        ;;


                    exe|*)

                        dart compile exe -o $filename.exe $filename.dart

                        ;;

                esac

                return $?

                ;; # }}}
            dotnet-publish) # {{{

                dotnet publish -c Release -p:PublishSingleFile=true -p:PublishTrimmed=true --self-contained true
                return $?

                ;; # }}}
            compare-compilations) # {{{

                mm_trim '

                    Creating the same program that would simply print "hello
                    world" to the console yields very different size of binaries depending on the tooling that is used.

                    Examples:

                        28jul24/13h12:

                            - TypeScript + Deno: 80M
                            - Dart: 5.4M
                            - F#:
                                - PublishTrimmed=false: 68M
                                - PublishTrimmed=true:  14M
                ' 12

                return 0

                ;; # }}}
            next_case_here) # {{{

                echo '\nA placeholder for the next case.'
                return 1

                ;; # }}}
            *) # {{{

                fatal "Unknown parameter passed: $1"

                ;; # }}}
        esac
        shift
    done
}

main "$@"

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
