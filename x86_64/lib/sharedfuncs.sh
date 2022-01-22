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
    if [ "${USER}" == "root" ]; then
        echo "This script is supposed to be run as a user, not as root."
        exit 1
    fi
}
bail_on_user() {
    if [ "${USER}" != "root" ]; then
        echo "This script is supposed to be run as a root, not as user."
        exit 1
    fi
}
