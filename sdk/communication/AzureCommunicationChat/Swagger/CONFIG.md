```
autorest
--swift
--input-file=https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/specification/communication/data-plane/Microsoft.CommunicationServicesChat/stable/2021-03-07/communicationserviceschat.json
--output-folder=<PATH TO AZURE SDK FOR IOS>/azure-sdk-for-ios/sdk/communication/AzureCommunicationChat
--use=<PATH TO AUTOREST>
--namespace=AzureCommunicationChat
--remap-models="CreateChatThreadResult=CreateChatThreadResultInternal CreateChatThreadRequest=CreateChatThreadRequestInternal ChatMessage=ChatMessageInternal ChatMessageContent=ChatMessageContentInternal ChatParticipant=ChatParticipantInternal ChatMessageReadReceipt=ChatMessageReadReceiptInternal ChatThreadProperties=ChatThreadPropertiesInternal CommunicationError=ChatError"
```
