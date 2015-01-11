include /Users/jamesaustin/theos/makefiles/common.mk


THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 armv7s arm64
TARGET_CC = xcrun -sdk iphoneos clang 
TARGET_CXX = xcrun -sdk iphoneos clang++
TARGET_LD = xcrun -sdk iphoneos clang++
SHARED_CFLAGS = -fobjc-arc -objc_arc

TWEAK_NAME = MessageServer
MessageServer_FILES = MessageServer.xm MSHTTPConnection.xm
MessageServer_FRAMEWORKS = UIKit ChatKit Foundation
MessageServer_PRIVATE_FRAMEWORKS = CoreTelephony Chatkit IMCore CFNetwork Security CoreGraphics
MessageServer_LDFLAGS = -lsqlite3 -lCocoaHTTPServer -lxml2

include /Users/jamesaustin/theos/makefiles/tweak.mk

internal-after-install::
	install.exec "killall -9 MobileSMS"
	
