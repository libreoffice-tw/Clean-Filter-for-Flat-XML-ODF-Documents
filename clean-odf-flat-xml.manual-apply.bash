#!/usr/bin/env bash
# shellcheck disable=SC2034

# Clean filter for Flat-XML ODF wrapper for manual applying
# 林博仁 © 2016
# Ｖ字龍 © 2017

# Comments prefixed by BASHDOC: are hints to specific GNU Bash Manual's section:
# https://www.gnu.org/software/bash/manual/

## Makes debuggers' life easier - Unofficial Bash Strict Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
## BASHDOC: Shell Builtin Commands - Modifying Shell Behavior - The Set Builtin
### Exit prematurely if a command's return value is not 0(with some exceptions), triggers ERR trap if available.
set -o errexit

### Trap on `ERR' is inherited by shell functions, command substitutions, and subshell environment as well
set -o errtrace

### Exit prematurely if an unset variable is expanded, causing parameter expansion failure.
set -o nounset

### Let the return value of a pipeline be the value of the last (rightmost) command to exit with a non-zero status
set -o pipefail

## Non-overridable Primitive Variables
##
## BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki
## http://mywiki.wooledge.org/BashFAQ/028
RUNTIME_EXECUTABLE_FILENAME="$(basename "${BASH_SOURCE[0]}")"
declare -r RUNTIME_EXECUTABLE_FILENAME
declare -r RUNTIME_EXECUTABLE_NAME="${RUNTIME_EXECUTABLE_FILENAME%.*}"
RUNTIME_EXECUTABLE_DIRECTORY="$(dirname "$(realpath --strip "${0}")")"
declare -r RUNTIME_EXECUTABLE_DIRECTORY
declare -r RUNTIME_EXECUTABLE_PATH_ABSOLUTE="${RUNTIME_EXECUTABLE_DIRECTORY}/${RUNTIME_EXECUTABLE_FILENAME}"
declare -r RUNTIME_EXECUTABLE_PATH_RELATIVE="${0}"
declare -r RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-${0}}"

trap_errexit(){
	printf "An error occurred and the script is prematurely aborted\n" 1>&2
	return 0
}; declare -fr trap_errexit; trap trap_errexit ERR

trap_exit(){
	return 0
}; declare -fr trap_exit; trap trap_exit EXIT

check_runtime_dependencies(){
	for a_command in cat mktemp mv; do
		if ! command -v "${a_command}" &>/dev/null; then
			printf "ERROR: %s command not found.\n" "${a_command}" 1>&2
			return 1
		fi
	done
	return 0
}

## init function: program entrypoint
init(){
	if ! check_runtime_dependencies; then
		exit 1
	fi

	global_temp_file="$(mktemp --tmpdir "${RUNTIME_EXECUTABLE_NAME}.XXXX")"
	declare -gr global_temp_directory

	if [ "${#}" -ne 1 ]; then
		printf "錯誤：參數數量錯誤。\n" 1>&2
		printf "資訊：使用方式：%s 〈要套用過濾器的檔案〉\n" "${RUNTIME_SCRIPT_NAME}" 1>&2
		exit 1
	fi

	local target_file="${1}"; shift

	"${RUNTIME_EXECUTABLE_DIRECTORY}"/clean-odf-flat-xml.bash <"${target_file}" >"${global_temp_file}"
	cat "${global_temp_file}" >"${target_file}"

	exit 0
}; declare -fr init
init "${@}"

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version:
declare -r META_BASED_ON_GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="v1.24.1"
## You may rebase your script to incorporate new features and fixes from the template
