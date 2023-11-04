import SwiftUI

struct ExamsSectionLabeledContentStyle: LabeledContentStyle {
    var font: Font = .headline
    var highlightTitle = false

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.label
                .font(font)
                .underline(highlightTitle, pattern: .solid, color: .secondary.opacity(0.5))

            configuration.content
        }
        .padding(.top, 4)
    }
}
