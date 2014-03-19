# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-hungermeter

QMAKE_CXXFLAGS += -std=c++0x

CONFIG += sailfishapp

QT += sql

SOURCES += src/HungerMeter.cpp \
    src/helper.cpp \
    src/HungerDaemon.cpp

OTHER_FILES += \
    qml/CoverPage.qml \
    HungerMeter-big.png \
    harbour-hungermeter.png \
    rpm/harbour-hungermeter.spec \
    harbour-hungermeter.desktop \
    rpm/harbour-hungermeter.yaml \
    qml/harbour-hungermeter.qml \
    qml/Consumption.qml \
    qml/Battery.qml \
    qml/Settings.qml \
    qml/About.qml

HEADERS += \
    src/hunger.h

