//
//  ViewRecorder.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2019/08/28.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

class ViewRecorder {

    private static var activeSessions: [Int: ViewRecordingSession] = [:]

    static func beginSession(for view: UIView) {
        guard activeSessions[view.hash] == nil else {
            return
        }

        let session = ViewRecordingSession(target: view)
        activeSessions[view.hash] = session
        session.start()
    }

    static func cancelSession(for view: UIView) {
        guard let session = activeSessions[view.hash] else {
            return
        }
        session.stop()
        activeSessions[view.hash] = nil
    }

    static func endSession(for view: UIView) -> [UIImage] {
        guard let session = activeSessions[view.hash] else {
            return []
        }
        session.stop()
        activeSessions[view.hash] = nil
        return session.frames
    }
}

// MARK: - Session

private class ViewRecordingSession {

    /// Target might get deallocated mid-session.
    weak var targetView: UIView?

    var displayLink: CADisplayLink?

    var frames: [UIImage] = []

    init(target: UIView) {
        self.targetView = target
    }

    func start() {
        guard displayLink == nil else {
            fatalError("View Recording Session Already Started!")
        }
        self.displayLink = CADisplayLink(target: self, selector: #selector(step(_:)))
        displayLink?.preferredFramesPerSecond = 30
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc func step(_ sender: CADisplayLink) {
        guard let view = targetView else {
            return
        }

        guard let newFrame = view.render() else {
            //print("Failed to acquire frame")
            return
        }
        self.frames.append(newFrame)
    }

    func stop() {
        displayLink?.invalidate()
    }
}
