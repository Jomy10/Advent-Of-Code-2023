clean() {
	echo "Cleaning build folders..."
	for file in day*; do
		if [ -d $file/.build ]; then
			rm -rf $file/.build
		fi
	done
}

run() {
	arg_len=${#1}
	if [[ $arg_len == 1 ]]; then
		cd day0$1
	else
		cd day$1
	fi
	swift run $2
}

eval "$@"

