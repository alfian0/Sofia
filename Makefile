install: check_xcodegen run_xcodegen

check_xcodegen:
ifeq (, $(shell which xcodegen))
	echo "No xcodegen install."
    echo "try to install xcodegen using brew."
    echo ""
    ./opt/homebrew/bin/xcodegen brew install xcodegen
    echo ""
    echo "success install xcodegen using brew."
    echo "try to run xcodegen again."
    echo ""
endif

run_xcodegen:
ifeq (, $(wildcard ./project.yml))
	echo "no project.yml files."
	echo ""
	exit 1
else
	xcodegen generate
	echo ""
	echo "xcodeproject success been build."
	echo ""
endif
