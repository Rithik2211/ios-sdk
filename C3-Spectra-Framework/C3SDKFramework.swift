//
//  C3SDKFramework.swift
//  C3-Spectra-Framework
//
//  Created by Rithik Pranao on 22/08/24.
//

import SwiftUI

public class C3SDKFramework {
    public static func presentSDK(from viewController: UIViewController) {
        let hostingController = UIHostingController(rootView: SDKUIView(onClose: {
            viewController.dismiss(animated: true, completion: nil)
        }))
        viewController.present(hostingController, animated: true, completion: nil)
    }
}
