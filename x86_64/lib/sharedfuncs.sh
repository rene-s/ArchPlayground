# Ask user a question and read the input
function ask() {
	TITLE=$1
	BACK_TITLE=$2
	INPUT_BOX=$3
	DEFAULT=$4
	OUTPUT=$(mktemp)

	trap 'rm $OUTPUT; exit' SIGHUP SIGINT SIGTERM

	dialog --title "${TITLE}" \
	--backtitle "${BACK_TITLE}" \
	--inputbox "${INPUT_BOX} " 8 60 "${DEFAULT}" 2>"$OUTPUT"

	ask_result=$?
	# shellcheck disable=SC2034
	answer=$(<"$OUTPUT")

	return $ask_result
}
bail_on_root() {
    if [ "$(whoami)" == "root" ]; then
        echo "This script is supposed to be run as a user, not as root."
        exit 1
    fi
}
bail_on_user() {
    if [ "$(whoami)" != "root" ]; then
        echo "This script is supposed to be run as a root, not as user."
        exit 1
    fi
}
yay_inst_pkg() {
  PKG="$1"
  yay -Q "${PKG}" || yay -S --noconfirm "${PKG}"
}

pacman_inst_pkg() {
  PKG="$1"
  sudo pacman -Q "${PKG}" || pacman -S --noconfirm "${PKG}"
}

add_line_to_file() {
    local line_to_add="$1"
    local file_path="$2"

    # Check if the file exists. If not, create it.
    if [ ! -f "$file_path" ]; then
        touch "$file_path"
    fi

    # Check if the line is already in the file. If not, append it.
    if ! grep -qxF "$line_to_add" "$file_path"; then
        echo "$line_to_add" >> "$file_path"
    fi
}