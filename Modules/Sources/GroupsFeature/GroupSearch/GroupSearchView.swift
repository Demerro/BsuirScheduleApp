import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

extension View {
    func groupSearchable(store: StoreOf<GroupSearch>) -> some View {
        modifier(GroupSearchViewModifier(store: store))
    }
}

struct GroupSearchViewModifier: ViewModifier {
    let store: StoreOf<GroupSearch>
    @Environment(\.dismissSearch) private var dismissSearch

    func body(content: Content) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content
                .modifier(StudentGroupSearchable(
                    text: viewStore.binding(\.$query),
                    prompt: viewStore.prompt.map { Text($0) },
                    tokens: viewStore.binding(\.$tokens),
                    suggestedTokens: viewStore.binding(\.$suggestedTokens)
                ))
                .onChange(of: viewStore.dismiss) { dismiss in
                    if dismiss { dismissSearch() }
                }
//                .task(id: viewStore.query, throttleFor: 300_000_000) {
//                    await viewStore.send(.filter, animation: .default).finish()
//                }
        }
    }
}

private struct StudentGroupSearchable: ViewModifier {
    @Binding var text: String
    var prompt: Text?
    @Binding var tokens: [StrudentGroupSearchToken]
    @Binding var suggestedTokens: [StrudentGroupSearchToken]

    func body(content: Content) -> some View {
        Group {
            if #available(iOS 16, *) {
                content
                    .searchable(
                        text: $text,
                        tokens: $tokens,
                        suggestedTokens: $suggestedTokens,
                        prompt: prompt,
                        token: { token in
                            switch token {
                            case let .faculty(value):
                                Text(value)
                            case let .speciality(value):
                                Text(value)
                            case let .course(value?):
                                Text("screen.groups.search.suggested.course.\(String(value))")
                            case .course(nil):
                                Text("screen.groups.search.suggested.noCourse")
                            }
                        })
            } else {
                content
                    .searchable(text: $text, prompt: prompt)
            }
        }
    }
}
