# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = HungerMeter

QMAKE_CXXFLAGS += -std=c++0x

CONFIG += sailfishapp

SOURCES += src/HungerMeter.cpp

OTHER_FILES += qml/HungerMeter.qml \
    qml/CoverPage.qml \
    qml/FirstPage.qml \
    rpm/HungerMeter.spec \
    rpm/HungerMeter.yaml \
    HungerMeter.desktop

HEADERS += \
    src/hunger.h

