#!/usr/bin/env sh
# vim:fdm=marker:fmr={{{,}}}:fdl=0:fen:
#
# manage.sh - Script to manage the project.
#

# Load shell helpers, define constants, install this script. {{{
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
# }}}


# All commands should be add here, along with description of how to use them.
usage() {
    mm_trim "
    Usage: cli [command]

    Commands
        - help: Show this message.
        - edit: Edit this file (alias: e, -e, --edit).
        - cron: Open crontab file.
        - fsharp:
            Create an F# project preinstalled with Fantomas for source
            formatting.
        - commitlint: Setup commit linting with husky and conventional commits.
        - pandoc: Print a pandoc man example command, with groff.
        - common: Edit shell helpers.
        - commonp: Edit personal shell helpers.
        - dartjs: Compile dart to js with level 2 of optimizations.
        - dotnet-publish:
            Create a release self contained binary of a dotnet project.
        - compare-compilations: Compare the binary size of hello world programs.
        - install-protoc:
            Install protocol buffers compiler. For details and more information,
            see the https://grpc.io/docs/protoc-installation/ page.
        - json-to-yaml: Convert a json file into yaml. Requires Deno.
        - example-inline-script: Show how to create an inline script here.
        - install-python-typings:
            Install mypy, to check Python files that use type hints. More
            details in their GitHub page:
                https://github.com/python/mypy
        - mypy: Run Python typechecker.
        - tsconfig: Create a new tsconfig files in the current directory.
    " 4

}


if [ $# -eq 0 ]; then
    usage
    echo
    fatal 'Invalid option'
fi



# Parses cli arguments and run the selected commands. Note that all functions
# should be defined inside the command case statement, to avoid mixing one
# command with the other.
main() {
    local editor="${EDITOR:-vi}"

    # Process command line arguments.
    while [ $# -gt 0 ]; do
        case "$1" in
            help|-h|--help|"") # {{{

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
            install-protoc) # {{{

                fatal_extra() {
                    echo 'Updated instructions here:'
                    echo '  https://grpc.io/docs/protoc-installation/'
                    fatal "$1"
                }

                local pb_releases='https://github.com/protocolbuffers/protobuf/releases'
                local protoc_version='27.2'
                local protoc_zip_filename="protoc-$protoc_version-linux-x86_64.zip"
                local protoc_zip_path="$pb_releases/download/v$protoc_version/$protoc_zip_filename"
                local protoc_local_dir="$HOME/bin/binaries/protoc/v$protoc_version"
                if [ ! -d "$protoc_local_dir" ]; then
                    mkdir -p "$protoc_local_dir"
                fi

                curl -LO "$protoc_zip_path" || fatal_extra 'Failed to download protoc zip'
                unzip $protoc_zip_filename -d $protoc_local_dir || fatal_extra 'Failed to extract protoc zip'

                echo 'Symlinking to a location present in PATH...'
                ln -s "$protoc_local_dir/bin/protoc" "$HOME/bin/protoc" \
                    || fatal_extra "Symlink '$protoc_local_dir/bin/protoc' to a location in your PATH"

                return 0

                ;; # }}}
            install-grpc-dart) # {{{

                echo 'See details here:'
                echo '  https://grpc.io/docs/languages/dart/quickstart/'
                return 1

                ;; # }}}
            json-to-yaml) # {{{

                if [ -z "$2" ] || [ -z "$3" ]
                then
                    fatal 'Usage: json-to-yaml <path to json> <path to yaml>'
                fi

                # File paths.
                local json_input="$2"
                local yaml_output="$3"

                deno run --allow-read --allow-write "$this_file_directory/scripts/json-to-yaml.ts"  $json_input  "$yaml_output"

                return $?

                ;; # }}}
            example-inline-script) # {{{

                # One-liner (of sorts... the command is in one line, not the
                # script).
                #
                # Notice that the script could be in any language and we could
                # run it with any command afterwards.
                #
                # I'm using 'EOF' to avoid variable substitution in the heredoc.
                file_to_run="$(mktemp)" && cat <<'EOF' > $file_to_run && dart run $file_to_run
import "dart:io";

void main() async {
    var dir = Directory('.');

    try {
        var dirList = dir.list();
        await for (final FileSystemEntity f in dirList) {
            if (f is File) {
                print('Found file ${f.path}');
            } else if (f is Directory) {
                print('Found dir ${f.path}');
            }
        }
    } catch (e) {
        print(e.toString());
    }
}

EOF
                ;; # }}}
            install-python-typings) # {{{

                # The -U is for `upgrade`.
                python3 -m pip install -U mypy || fatal 'Failed to install mypy'
                return 0

                ;; # }}}
            mypy) # {{{

                case "$2" in
                    *.py)
                        mypy $2
                        return $?
                        ;;
                    *)
                        fatal '\nERROR. Please, provide a Python file.'
                        ;;
                esac

                ;; # }}}
            tsconfig) # {{{

                npx --package=typescript@5.5.4 -- tsc --init
                return $?

                ;; # }}}
            *) # Put the next command above this line. {{{

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
