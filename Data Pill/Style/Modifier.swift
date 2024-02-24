//
//  Modifier.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct StepperTip: ViewModifier {
    // MARK: Props
    @Binding var hasShownStepperTip: Bool
    var isBelow: Bool
    
    // MARK: UI
    var tip: some View {
        Group {
            if !hasShownStepperTip {
                
                Text("Tip: Long press - or + to change precision")
                    .textStyle(
                        foregroundColor: .onBackgroundLight,
                        font: .semibold,
                        size: 14,
                        lineLimit: 2,
                        lineSpacing: 2,
                        textAlignment: .leading
                    )
                    .fillMaxWidth(alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Colors.surface.color)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
                            withAnimation {
                                hasShownStepperTip = true
                            }
                        }
                    }
                
            } //: if
        }
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 21) {
            
            if !isBelow {
                tip
            }
            
            content
            
            if isBelow {
                tip
            }
            
        } //: VStack
    }
}

extension View {
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        _ transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a light shadow to a view
    /// Mainly used for a `Item Card View`
    /// - Returns: The `View` with applied shadow
    func cardShadow(
        radius: CGFloat = 10,
        y: CGFloat = 2,
        opacity: Double = 0.1,
        scheme: ColorScheme
    ) -> some View {
        let color: Color = (scheme == .light) ? .black : .white
        return self
            .shadow(
                color: color.opacity(opacity),
                radius: radius,
                y: y
            )
    }
    
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
    
    func hideNavigationBar() -> some View {
        if #available(iOS 16, *) {
            return self.toolbar(.hidden)
        } else {
            return self.navigationBarHidden(true)
        }
    }
    
    func withStepperTip(hasShownStepperTip: Binding<Bool>, isBelow: Bool) -> some View {
        modifier(StepperTip(hasShownStepperTip: hasShownStepperTip, isBelow: isBelow))
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
