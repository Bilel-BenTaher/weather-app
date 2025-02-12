include(third_party/android_openssl/openssl.pri)

QT += quick network svg positioning

CONFIG += c++17

# for translations: automatically compile .ts files to .qm and make them
# available to the Qt Resource System
CONFIG += lrelease embed_translations

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    src/WeatherApi.cpp \
    src/WeatherData.cpp \
    src/WeatherDataModel.cpp \
    src/main.cpp

HEADERS += \
    src/WeatherApi.h \
    src/WeatherData.h \
    src/WeatherDataModel.h

RESOURCES += res/qml/qml.qrc \
       res/fonts/fonts.qrc \
       res/icons/icons.qrc

# supported languages for translation
LANGUAGES = en de

# parameters: var, prepend, append
defineReplace(prependAll) {
 for(a,$$1):result += $$2$${a}$$3
 return($$result)
}

TRANSLATIONS = $$prependAll(LANGUAGES, $$PWD/i18n/Weather-App_, .ts)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/res/values/strings.xml

ANDROID_PACKAGE_SOURCE_DIR = \
    $$PWD/android
