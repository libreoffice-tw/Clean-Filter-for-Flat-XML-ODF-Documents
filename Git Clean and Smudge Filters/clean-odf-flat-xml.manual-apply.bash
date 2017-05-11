#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# Clean filter for Flat-XML ODF wrapper for manual applying
# 林博仁 © 2016
# Ｖ字龍 © 2017

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
declare -r PROGRAM_FILENAME="$(basename "$0")"
declare -r PROGRAM_DIRECTORY="$(realpath --no-symlinks "$(dirname "$0")")"
declare -r PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
declare -r PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

## Unofficial Bash Script Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
# 將未定義的變數的參考視為錯誤
set -u

# Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status.  The shell does not exit if the command that fails is part of the command list immediately following a `while' or `until' keyword, part of the test in an `if' statement, part of any command executed in a `&&' or `||' list except the command following the final `&&' or `||', any command in a pipeline but the last, or if the command's return status is being inverted with `!'.  If a compound command other than a subshell returns a non-zero status because a command failed while `-e' was being ignored, the shell does not exit.  A trap on `ERR', if set, is executed before the shell exits.
set -e

# If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

######## File scope variable definitions ended ########

######## Included files ########

######## Included files ended ########

######## Program ########
# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	local target_file_path="$PROGRAM_ARGUMENT_ORIGINAL_LIST"

	if [ $PROGRAM_ARGUMENT_ORIGINAL_NUMBER -ne 1 ]; then
		printf "錯誤：參數數量錯誤。\n" 1>&2
		printf "資訊：使用方式：$PROGRAM_FILENAME 〈要套用過濾器的檔案〉\n"
		exit 1
	else
		local temp_file_name="$(basename "$target_file_path").new" # Argument list is single filename
		local temp_file="$PROGRAM_DIRECTORY/$temp_file_name"

		rm --force "$temp_file"

		cat "$PROGRAM_ARGUMENT_ORIGINAL_LIST" | "$PROGRAM_DIRECTORY/$(basename --suffix=.manual-apply.bash "${PROGRAM_FILENAME}").bash" >"$temp_file"

		mv --force "$temp_file" "$PROGRAM_ARGUMENT_ORIGINAL_LIST"

		exit 0
	fi
	# Shouldn't be here
}
main

