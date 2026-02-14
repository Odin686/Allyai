import SwiftUI

extension Font {
    static let aiLargeTitle = Font.system(.largeTitle, design: .rounded).bold()
    
    static func aiTitle() -> Font {
        Font.system(.title, design: .rounded).bold()
    }
    
    static func aiTitle2() -> Font {
        Font.system(.title2, design: .rounded).bold()
    }
    
    static func aiTitle3() -> Font {
        Font.system(.title3, design: .rounded).bold()
    }
    
    static func aiHeadline() -> Font {
        Font.system(.headline, design: .rounded)
    }
    
    static func aiBody() -> Font {
        Font.system(.body, design: .rounded)
    }
    
    static func aiCallout() -> Font {
        Font.system(.callout, design: .rounded)
    }
    
    static func aiSubheadline() -> Font {
        Font.system(.subheadline, design: .rounded)
    }
    
    static func aiCaption() -> Font {
        Font.system(.caption, design: .rounded)
    }
    
    static func aiCaption2() -> Font {
        Font.system(.caption2, design: .rounded)
    }
    
    static func aiRounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        Font.system(style, design: .rounded).weight(weight)
    }
    
    static func aiXP() -> Font {
        Font.system(size: 18, weight: .heavy, design: .rounded)
    }
    
    static func aiLevel() -> Font {
        Font.system(size: 14, weight: .bold, design: .rounded)
    }
    
    static func aiStreak() -> Font {
        Font.system(size: 22, weight: .black, design: .rounded)
    }
}
