/**
 ** This file is part of the "Mobile Weather" project.
 ** Copyright (c) 2020 Florian Meinicke <florian.meinicke@t-online.de>.
 **
 ** Permission is hereby granted, free of charge, to any person obtaining a copy
 ** of this software and associated documentation files (the "Software"), to deal
 ** in the Software without restriction, including without limitation the rights
 ** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ** copies of the Software, and to permit persons to whom the Software is
 ** furnished to do so, subject to the following conditions:
 **
 ** The above copyright notice and this permission notice shall be included in all
 ** copies or substantial portions of the Software.
 **
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ** SOFTWARE.
 **/

//============================================================================
/// \file   main.qml
/// \author Florian Meinicke <florian.meinicke@t-online.de>
/// \date   06/02/2020
/// \brief  The starting screen of the app
//============================================================================
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.3
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12
import QtQml.StateMachine 1.0 as DSM

ApplicationWindow {
  id: window

  visible: true
  width: ScreenInfo.width
  height: ScreenInfo.height

  header: ToolBar {
    contentHeight: hamburgerMenuButton.implicitHeight
    contentWidth: ScreenInfo.width

    RowLayout {
      anchors.fill: parent

      ToolButton {
        id: hamburgerMenuButton

        icon.source: stackView.depth > 1 ? "qrc:/icons/arrow_back_white" :
                                           "qrc:/icons/hamburger_menu_white"
        icon.color: 'transparent'

        onClicked: {
          if (stackView.depth > 1) {
            stackView.pop()
          } else {
            drawer.open()
          }
        }
      }

      Label {
        text: stackView.currentItem.title
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        horizontalAlignment: Qt.AlignHCenter
        Layout.fillWidth: true
      }

      ToolButton {
        id: searchButton

        property Item currentSearchPage

        icon.source: "qrc:/icons/search_white"
        icon.color: 'transparent'
        Layout.alignment: Qt.AlignRight
        Layout.rightMargin: -width / 3

        onClicked: {
          // prevent "SearchPageForm" to be pushed onto the stack multiple times
          if (!currentSearchPage
              || currentSearchPage != stackView.currentItem) {
            currentSearchPage = stackView.push("SearchPageForm.qml")
          }
        }
      }

      ToolButton {
        id: menuButton

        icon.source: "qrc:/icons/three_dots_white"
        icon.color: 'transparent'

        Layout.alignment: Qt.AlignTop
        font.pixelSize: Qt.application.font.pixelSize * 1.6

        onClicked: menu.toggle()
      }
    }
  }

  Menu {
    id: menu

    property bool isOpen: false

    x: window.width - width - 2
    width: menuFav.implicitWidth

    MenuItem {
      id: menuFav

      state: weatherApi.favouriteLocations.includes(stackView.currentItem.title) ?
               "remove" : "add"

      enabled: stackView.currentItem.objectName === "WeatherForecastPage" &&
               stackView.currentItem.state !== "noLocation"

      states: [
        State {
          name: "add"
          PropertyChanges {
            target: menuFav
            text: qsTr("Add Location to Favourites")

            onTriggered: {
              paneUndoFavLocation.show(qsTr("Added %1 to Favourites")
                                       .arg(stackView.currentItem.title))
              weatherApi.addCurrentLocationToFavourites()
              // don't show the button as highlighted after it has been clicked
              // this makes no sense
              highlighted = false
            }
          }
          PropertyChanges {
            target: btnUndo

            onClicked: {
              // This undo action can only be triggered after a location has
              // already been removed. Therefore the state will be "add" again
              // instead of "remove". Hence this undo action actually belongs to
              // the "remove" state and re-adds the removed location.
              weatherApi.addCurrentLocationToFavourites()
              stateMachine.running = false
            }
          }
        },
        State {
          name: "remove"
          PropertyChanges {
            target: menuFav
            text: qsTr("Remove Location from Favourites")

            onTriggered: {
              paneUndoFavLocation.show(qsTr("Removed %1 from Favourites")
                                       .arg(stackView.currentItem.title))
              weatherApi.removeCurrentLocationFromFavourites()
              // don't show the button as highlighted after it has been clicked
              // this makes no sense
              highlighted = false
            }
          }
          PropertyChanges {
            target: btnUndo

            onClicked: {
              // This undo action can only be triggered after a location has
              // already been added. Therefore the state will be "remove" again
              // instead of "add". Hence this undo action actually belongs to
              // the "add" state and removes the added location.
              weatherApi.removeCurrentLocationFromFavourites()
              stateMachine.running = false
            }
          }
        }
      ]
    }

    MenuItem {
      id: menuAbout

      property Item currentAboutPage

      text: qsTr("About")

      onTriggered: {
        // prevent "AboutPage" to be pushed onto the stack multiple times
        if (stackView.currentItem.title !== qsTr("About")) {
          stackView.push("AboutPage.qml")
        }
        // don't show the button as highlighted after it has been clicked
        // this makes no sense
        highlighted = false
      }
    }

    onClosed: isOpen = false

    function toggle() {
      if (isOpen) {
        close()
      } else {
        open()
      }
      isOpen = !isOpen
    }
  }

  Drawer {
    id: drawer

    width: window.width * 0.66
    height: window.height

    Column {
      anchors.fill: parent

      Label {
        id: lblColumnHeader

        text: qsTr("Favourite Locations")
        font.pointSize: Qt.application.font.pointSize
        font.bold: true

        width: parent.width
        height: 48
        leftPadding: 10
        verticalAlignment: Text.AlignVCenter
      }

      Repeater {
        model: weatherApi.favouriteLocations
        delegate: ItemDelegate {
          text: qsTr(modelData)
          font.pointSize: lblColumnHeader.font.pointSize
          width: parent.width

          onClicked: {
            weatherApi.setLocationByName(modelData)
            weatherApi.requestWeatherData()
            drawer.close()
          }
        }
      }
    }
  }

  StackView {
    id: stackView

    anchors.fill: parent
    initialItem: "WeatherForecastPageForm.qml"


    // Implements back key navigation
    focus: true
    property bool wantsQuit: false

    onFocusChanged: {
      if (!focus) {
        forceActiveFocus()
      }
    }

    Timer {
      id: timer
      interval: 2100
      running: stackView.wantsQuit
      repeat: false
      onTriggered: {
        // user didn't press back twice within the small intervall - doesn't want to quit
        stackView.wantsQuit = false
      }
    }

    ToolTip {
      id: quitMsg

      text: qsTr("Press again to quit...")
      y: parent.height - 50
      visible: stackView.wantsQuit
      timeout: timer.interval
      delay: 500

      onClosed: {
        if (stackView.wantsQuit) {
          // user pressed back button twice within a small intervall - quit app
          window.close()
        }
      }
    }

    Keys.onBackPressed: {
      if (depth > 1) {
        // if not on the main page, don't close the app on back key press
        // just go back one page
        wantsQuit = false
        pop()
      } else if (!wantsQuit) {
        // close on next back button press
        wantsQuit = true
      }
    }
  }

  Pane {
    id: paneUndoFavLocation

    property string text

    /**
    * @brief Show the undo pane at he bottom of the screen displaying the given
    * message @a text.
    *
    * @param text The message to display when showing the pane
    */
    function show(text) {
      paneUndoFavLocation.text = text
      stateMachine.running = true
    }

    opacity: stateMachine.running

    Behavior on opacity {
      NumberAnimation {
        easing.type: Easing.InOutQuad
        duration: 400
      }
    }

    Material.theme: Material.Dark

    height: 48
    width: parent.width
    anchors.bottom: parent.bottom

    RowLayout {
      anchors.topMargin: -11
      anchors.fill: parent

      Label {
        text: paneUndoFavLocation.text
      }

      Button {
        id: btnUndo

        text: qsTr("Undo")
        flat: true
        Material.foreground: Material.Yellow

        Layout.alignment: Qt.AlignRight
      }
    }

    DSM.StateMachine {
      id: stateMachine

      initialState: hidden
      running: false

      DSM.State {
        id: hidden
        DSM.TimeoutTransition {
          targetState: shown
          timeout: 2500
        }
      }

      DSM.FinalState {
        id: shown
      }
    }
  }
}
