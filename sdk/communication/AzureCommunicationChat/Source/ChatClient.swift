// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCommunication
import AzureCore
import Foundation

public class ChatClient {
    // MARK: Properties

    private let endpoint: String
    private let credential: CommunicationTokenCredential
    private let options: AzureCommunicationChatClientOptions
    private let service: Chat
    private let signallingClient: CommunicationSignallingClient?
    private var isRealtimeNotificationsStarted: Bool = false

    // MARK: Initializers

    /// Create a ChatClient.
    /// - Parameters:
    ///   - endpoint: The Communication Services endpoint.
    ///   - credential: The user credential.
    ///   - options: Options used to configure the client.
    public init(
        endpoint: String,
        credential: CommunicationTokenCredential,
        withOptions options: AzureCommunicationChatClientOptions
    ) throws {
        self.endpoint = endpoint
        self.credential = credential
        self.options = options

        guard let endpointUrl = URL(string: endpoint) else {
            throw AzureError.client("Unable to form base URL.")
        }

        let communicationCredential = TokenCredentialAdapter(credential)
        let authPolicy = BearerTokenCredentialPolicy(credential: communicationCredential, scopes: [])

        let client = try AzureCommunicationChatClient(
            endpoint: endpointUrl,
            authPolicy: authPolicy,
            withOptions: options
        )

        self.service = client.chat

        // Initialize the signalling client with the users access token
        var token: String?
        credential.token { accessToken, _ in
            token = accessToken?.token
        }

        self.signallingClient = CommunicationSignallingClient(token: token)
    }

    // MARK: Private Methods

    /// Converts [ChatParticipant] to [ChatParticipantInternal] for internal use.
    /// - Parameter chatParticipants: The array of ChatParticipants.
    /// - Returns: An array of ChatParticipants.
    private func convert(chatParticipants: [ChatParticipant]?) throws -> [ChatParticipantInternal]? {
        guard let participants = chatParticipants else {
            return nil
        }

        return try participants.map { (participant) -> ChatParticipantInternal in
            let identifierModel = try IdentifierSerializer.serialize(identifier: participant.id)
            return ChatParticipantInternal(
                communicationIdentifier: identifierModel,
                displayName: participant.displayName,
                shareHistoryTime: participant.shareHistoryTime
            )
        }
    }

    // MARK: Public Methods

    /// Create a ChatThreadClient for the ChatThread with id threadId.
    /// - Parameters:
    ///   - threadId: The threadId.
    public func createClient(forThread threadId: String) throws -> ChatThreadClient {
        return try ChatThreadClient(
            endpoint: endpoint,
            credential: credential,
            threadId: threadId,
            withOptions: options
        )
    }

    /// Create a new ChatThread.
    /// - Parameters:
    ///   - thread: Request for creating a chat thread with the topic and optional members to add.
    ///   - options: Create chat thread options.
    ///   - completionHandler: A completion handler that receives a ChatThreadClient on success.
    public func create(
        thread: CreateChatThreadRequest,
        withOptions options: Chat.CreateChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<CreateChatThreadResult>
    ) {
        // Set the idempotencyToken if it is not provided
        let requestOptions = ((options?.idempotencyToken) != nil) ? options : Chat.CreateChatThreadOptions(
            idempotencyToken: UUID().uuidString,
            clientRequestId: options?.clientRequestId,
            cancellationToken: options?.cancellationToken,
            dispatchQueue: options?.dispatchQueue,
            context: options?.context
        )

        do {
            // Convert ChatParticipant to ChatParticipantInternal
            let participants = try convert(chatParticipants: thread.participants)

            // Convert to CreateChatThreadRequestInternal
            let request = CreateChatThreadRequestInternal(
                topic: thread.topic,
                participants: participants
            )

            service.create(chatThread: request, withOptions: requestOptions) { result, httpResponse in
                switch result {
                case let .success(chatThreadResult):
                    do {
                        let threadResult = try CreateChatThreadResult(from: chatThreadResult)
                        completionHandler(.success(threadResult), httpResponse)
                    } catch {
                        let azureError = AzureError.client(error.localizedDescription, error)
                        completionHandler(.failure(azureError), httpResponse)
                    }

                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
        } catch {
            // Return error from converting participants
            let azureError = AzureError.client("Failed to construct create thread request.", error)
            completionHandler(.failure(azureError), nil)
        }
    }

    /// Gets the list of ChatThreads for the user.
    /// - Parameters:
    ///   - options: List chat threads options.
    ///   - completionHandler: A completion handler that receives the list of chat thread items on success.
    public func listThreads(
        withOptions options: Chat.ListChatThreadsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatThreadItem>>
    ) {
        service.listChatThreads(withOptions: options) { result, httpResponse in
            switch result {
            case let .success(chatThreads):
                completionHandler(.success(chatThreads), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Delete the ChatThread with id chatThreadId.
    /// - Parameters:
    ///   - threadId: The chat thread id.
    ///   - options: Delete chat thread options.
    ///   - completionHandler: A completion handler.
    public func delete(
        thread threadId: String,
        withOptions options: Chat.DeleteChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        service.deleteChatThread(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                completionHandler(.success(()), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Start receiving realtime notifications.
    /// Call this function before subscribing to any event.
    public func startRealTimeNotifications() throws {
        if signallingClient == nil {
            throw AzureError.client("Signalling client is not initialized.")
        }

        if isRealtimeNotificationsStarted {
            return
        }

        isRealtimeNotificationsStarted = true
        signallingClient?.start()
    }

    /// Stop receiving realtime notifications.
    /// This function would unsubscribe to all events.
    public func stopRealTimeNotifications() throws {
        if signallingClient == nil {
            throw AzureError.client("Signalling client is not initialized.")
        }

        isRealtimeNotificationsStarted = false
        signallingClient?.stop()
    }

    /// Subscribe to chat events
    public func on(event: String, listener: @escaping EventListener) {
        guard let _ = ChatEventId(rawValue: event) else {
            options.logger.error("the event id provided is not supported")
            return
        }

        signallingClient?.on(event: event, listener: listener)
    }

    /// Unsubscribe to chat events
    public func off(event: String, listener: @escaping EventListener) {
        guard let _ = ChatEventId(rawValue: event) else {
            options.logger.error("the event id provided is not supported")
            return
        }

        signallingClient?.off(event: event, listener: listener)
    }
}
