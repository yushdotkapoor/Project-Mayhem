//
//  ProjectMayhemProducts.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/26/21.
//

import Foundation

public struct ProjectMayhemProducts {
    
    public static let hints = "com.YushRajKapoor.ProjectMayhem.betterHints"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [ProjectMayhemProducts.hints]
    
    public static let store = IAPHelper(productIds: ProjectMayhemProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

