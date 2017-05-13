#!/usr/bin/env bash
# shellcheck disable=SC2034

# Clean filter for Flat-XML ODF
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

## init function: program entrypoint
init(){
	printf "Clean 過濾器：正在移除非必要資訊跟美化 Flat XML ODF 標記代碼……\n" 1>&2

	# Catch the incoming stream to a temp file
	local temp_file
	temp_file="$(mktemp --tmpdir "$(basename "${RUNTIME_EXECUTABLE_NAME}")".XXXXXX)"

	rm --force "$temp_file"
	cat >"$temp_file"

	# 不追蹤存檔當前編輯軟體設定
	xml_delete_node "$temp_file" "/office:document/office:settings"

	# 不追蹤編輯軟體識別名稱
	xml_delete_node "$temp_file" "/office:document/office:meta/meta:generator"

	# 不追蹤編輯次數
	xml_delete_node "$temp_file" "/office:document/office:meta/meta:editing-cycles"

	# 不追蹤總編輯時間
	xml_delete_node "$temp_file" "/office:document/office:meta/meta:editing-duration"

	# 不追蹤文件統計資訊（列數、字數等）
	xml_delete_node "$temp_file" "/office:document/office:meta/meta:document-statistic"

	# 不追蹤從系統取得的預設字型資訊
	xml_delete_node "$temp_file" "/office:document/office:font-face-decls/style:font-face[@style:font-family-generic='system']"

	xml_delete_node "$temp_file" "/office:document/office:meta/dc:date"

	# 不追蹤預設(?)樣式資訊
	xml_delete_node "$temp_file" "/office:document/office:styles/style:default-style"

	# 不追蹤非必要且會變動的 xml:id 屬性
	xml_transform_node "${RUNTIME_EXECUTABLE_DIRECTORY}/$(basename --suffix=.bash "${RUNTIME_EXECUTABLE_NAME}").remove-xml-id-attributes.xslt" "$temp_file"

	xml_format_node "$temp_file"

	cat "$temp_file"

	rm "$temp_file"

	exit 0
}; declare -fr init

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version:
declare -r META_BASED_ON_GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="v1.24.1"
## You may rebase your script to incorporate new features and fixes from the template

xml_delete_node(){
	local xml_file="$1"
	local node_xpath="$2"

	local temp_file="${xml_file}.new"
	xmlstarlet edit --pf --ps --delete "$node_xpath" "$xml_file" >"$temp_file"
	mv --force "$temp_file" "$xml_file"
}

xml_transform_node(){
	local xsl_file="$1"
	local xml_file="$2"

	local temp_file="${xml_file}.new"
	xmlstarlet transform "$xsl_file" "$xml_file" >"${temp_file}"
	mv --force "$temp_file" "$xml_file"
}

xml_format_node(){
	local xml_file="$1"

	local temp_file="${xml_file}.new"
	xmlstarlet format --indent-tab "$xml_file" >"${temp_file}"
	mv --force "$temp_file" "$xml_file"
}

init "${@}"