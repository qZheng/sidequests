//
//  SideQuestsWidgetBundle.swift
//  SideQuestsWidget
//
//  Created by Lucas Zheng on 2025-08-02.
//

import WidgetKit
import SwiftUI
import AppIntents

@main
struct SideQuestsWidgetBundle: WidgetBundle {
    var body: some Widget {
        SideQuestsWidget()
        SideQuestsWidgetControl()
        SideQuestsWidgetLiveActivity()
    }
}

@available(iOS 17.0, *)
extension SideQuestsWidgetBundle: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        []   // no external packages to include
    }
}
