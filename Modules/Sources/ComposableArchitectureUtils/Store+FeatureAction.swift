import Foundation
import ComposableArchitecture

extension Store where Action: FeatureAction {
    public func scope<ChildState, ChildAction>(
        state toChildState: @escaping (State) -> ChildState,
        action fromChildAction: @escaping (ChildAction) -> Action.ReducerAction
    ) -> Store<ChildState, ChildAction> {
        scope(
            state: toChildState,
            action: { .reducer(fromChildAction($0)) }
        )
    }
    
    public func scope<ChildState, ChildAction>(
        state toChildState: @escaping (State) -> ChildState,
        action fromChildAction: CasePath<Action.ReducerAction, ChildAction>
    ) -> Store<ChildState, ChildAction> {
        scope(
            state: toChildState,
            action: fromChildAction.embed
        )
    }
}