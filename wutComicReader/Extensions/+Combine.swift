//
//  +Combine.swift
//  wutComicReader
//
//  Created by Sha Yan on 5/8/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import Combine
import CoreMedia

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T) -> AnyCancellable {
            return sink { [weak object] value in
                object?[keyPath: keyPath] = value
            }
    }
}
