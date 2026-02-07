import SwiftUI
import AVKit

struct AirPlayPickerButton: UIViewRepresentable {
    var tintColor: UIColor = UIColor(Color.stone)

    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = tintColor
        picker.activeTintColor = UIColor(Color.coral)
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
