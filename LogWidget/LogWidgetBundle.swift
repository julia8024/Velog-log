//
//  LogWidgetBundle.swift
//  LogWidget
//
//  Created by 장세희 on 2024/06/17.
//

import WidgetKit
import SwiftUI

@main
struct LogWidgetBundle: WidgetBundle {
    var body: some Widget {
        LogWidget()
        LogWidgetLiveActivity()
    }
}
