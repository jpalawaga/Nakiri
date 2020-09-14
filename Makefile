SUPPORTFILES=./SupportFiles/
PLATFORM=x86_64-apple-macosx
BUILD_DIRECTORY = ./.build/${PLATFORM}/debug
APP_DIRECTORY=./Nakiri.app
CFBUNDLEEXECUTABLE=Nakiri

install: build copySupportFiles

build:
	swift build --product ${CFBUNDLEEXECUTABLE}

copySupportFiles:
	mkdir -p ${APP_DIRECTORY}/Contents/MacOS/
	cp ${SUPPORTFILES}/MainInfo.plist ${APP_DIRECTORY}/Contents/Info.plist
	cp ${BUILD_DIRECTORY}/${CFBUNDLEEXECUTABLE}App ${APP_DIRECTORY}/Contents/MacOS/

run: clean install
	pkill ${CFBUNDLEEXECUTABLE} || true
	sleep 1
	open -Fa ${CFBUNDLEEXECUTABLE}

clean:
	rm -rf .build
	rm -rf ${APP_DIRECTORY}

.PHONY: run build copySupportFiles clean
