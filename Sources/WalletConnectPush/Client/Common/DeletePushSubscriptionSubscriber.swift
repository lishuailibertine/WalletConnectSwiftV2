import Foundation
import Combine
import WalletConnectKMS
import WalletConnectPairing

class DeletePushSubscriptionSubscriber {
    private let networkingInteractor: NetworkInteracting
    private let kms: KeyManagementServiceProtocol
    private let logger: ConsoleLogging
    private var publishers = [AnyCancellable]()
    private let pushSubscriptionStore: CodableStore<PushSubscription>

    private let deleteSubscriptionPublisherSubject = PassthroughSubject<String, Never>()

    public var deleteSubscriptionPublisher: AnyPublisher<String, Never> {
        deleteSubscriptionPublisherSubject.eraseToAnyPublisher()
    }

    init(networkingInteractor: NetworkInteracting,
         kms: KeyManagementServiceProtocol,
         logger: ConsoleLogging,
         pushSubscriptionStore: CodableStore<PushSubscription>
    ) {
        self.networkingInteractor = networkingInteractor
        self.kms = kms
        self.logger = logger
        self.pushSubscriptionStore = pushSubscriptionStore
        subscribeForDeleteSubscription()
    }

    private func subscribeForDeleteSubscription() {
        let protocolMethod = PushDeleteProtocolMethod()
        networkingInteractor.requestSubscription(on: protocolMethod)
            .sink { [unowned self] (payload: RequestSubscriptionPayload<PushDeleteParams>) in
                logger.debug("Peer deleted subscription")
                let topic = payload.topic
                networkingInteractor.unsubscribe(topic: topic)
                pushSubscriptionStore.delete(forKey: topic)
                kms.deleteSymmetricKey(for: topic)
                deleteSubscriptionPublisherSubject.send(payload.topic)
            }.store(in: &publishers)
    }
}
