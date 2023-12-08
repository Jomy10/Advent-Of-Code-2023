clean () {
	echo "Cleaning build folders..."
	for file in day*; do
		if [ -d $file/.build ]; then
			rm -rf $file/.build
		fi
	done
}

eval $1

