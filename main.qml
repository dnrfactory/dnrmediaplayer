import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15

Window {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Media Player")

    property string mediaSource: ""

    function play() {
        console.log("mediaSource: " + mediaSource)
        mediaPlayer.play()
    }

    function stop() {
        console.log("stop")
        mediaPlayer.stop()
    }

    MediaPlayer {
        id: mediaPlayer
        source: mediaSource

        onError: console.log("onError %1".arg(errorString))
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: mediaPlayer
    }

    Item {
        x: videoOutput.contentRect.x
        y: videoOutput.contentRect.y
        width: videoOutput.contentRect.width
        height: videoOutput.contentRect.height
        visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState

        Text {
            id: playbackStatusText
            text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? qsTr("\u25B6"): qsTr("\u275A\u275A")
            font.pointSize: mediaPlayer.playbackState === MediaPlayer.PlayingState ? 40 :30
            anchors.centerIn: parent
            opacity: 0

            OpacityAnimator {
                id: opacityAnimator
                target: playbackStatusText
                from: 1
                to: 0
                duration: 3000
                running: false
            }

            function startAnimation() {
                opacityAnimator.stop()
                playbackStatusText.opacity = 1
                opacityAnimator.start()
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mediaPlayer.playbackState === MediaPlayer.PlayingState ?
                mediaPlayer.pause() : mediaPlayer.play()

                playbackStatusText.startAnimation()
            }
        }

        Slider {
            id: durationSlider
            width: parent.width
            anchors.bottom: parent.bottom
            opacity: hovered || pressed ? 1 : 0

            from: 0
            to: mediaPlayer.duration

            value: mediaPlayer.position

            onPressedChanged: {
                mediaPlayer.seek(durationSlider.position * mediaPlayer.duration)
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                }
            }
        }
    }

    Connections {
        target: mediaPlayer
        function onPositionChanged() {
            if (durationSlider.pressed === false) {
                durationSlider.value = mediaPlayer.position
            }
        }
    }
}
