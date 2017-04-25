//
//  main.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit
import PortalApplication
import PortalView

let context = UIKitApplicationContext(
    application: Voices(),
    commandExecutor: VoicesCommandExecutor(),
    subscriptionManager: VoicesSubscriptionManager(),
    customComponentRenderer: VoidCustomComponentRenderer()
)

context.registerMiddleware(TimeLogger())

PortalUIApplication.start(applicationContext: context) { message in
        switch message {
        case .didFinishLaunching(_, _):
            return .applicationLaunched
        default:
            return .none
        }
}
