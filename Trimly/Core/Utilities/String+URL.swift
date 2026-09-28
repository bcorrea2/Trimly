import Foundation
import UIKit

extension String {
    func isValidURL() -> Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}