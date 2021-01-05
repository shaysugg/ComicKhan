//
//  ArrayOfStringTransformer.swift
//  wutComicReader
//
//  Created by Sha Yan on 1/5/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import Foundation

@objc(ArrayOfStringsTransformer)
public final class ArrayOfStringsTransformer: ValueTransformer {
    
    public override func transformedValue(_ value: Any?) -> Any? {
        
        guard let strings = value as? [String] else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: strings, requiringSecureCoding: true)
            return data
        }catch {
            assertionFailure("Failed to transform [String] to Data")
            return nil
        }
    }
    
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let unarchivedStrings = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)
            return unarchivedStrings
        }catch {
            assertionFailure("Failed to transform Date to [String]")
            return nil
        }
    }
    
    override public class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
}


extension ArrayOfStringsTransformer {
    static let name = NSValueTransformerName(String(describing: ArrayOfStringsTransformer.self))
    
    public static func register() {
        let transformer = ArrayOfStringsTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
