//
//  JointPurchasesPayJointPurchasesPayInteractor.swift
//  SBOLN-IOS
//
//  Created by Denis on 25/09/2017.
//  Copyright © 2017 Example. All rights reserved.
//


protocol JointPurchasesPayInteractorProtocol: class {
    func basicSelectCardObject() -> CreditCardObject?

    func connectToDatabaseService(delegate: POutputDatabaseService)
    
    func disconnectFromDatabaseService(delegate: POutputDatabaseService)
    
    func stateLoadingBalance(creditCard: CreditCardObject) -> StateLoadingBalance
    
    func refreshBalance(creditCard: CreditCardObject)
    
    func selectCardModels() -> [SelectCardModel]
    
    func basicSelectCardModel(from creditCard: CreditCardObject) -> SelectCardModel?
    
    func requestSetJointPurchases(model: AddressBookContactRequest, completionHandler: @escaping ((Result_<AddressBookContactRequest, SBNError<LoginRequestError>>) -> Void)) -> SBNRequest
    func getCreatorCard(requestId: Int?, completionHandler: @escaping ((Result_<JointCreatorCard, SBNError<LoginRequestError>>) -> Void)) -> SBNRequest
    func getParametsTransfer(cardId: String,
                             amount: Double,
                             currency: String,
                             beneficiaryCrmId: String?,
                             beneficiaryCardId: String?,
                             beneficiaryCardPan: String?,
                             beneficiaryCardExpire: Date?,
                             completionHandler: @escaping ((Result_<ApiParametersRefillDeposit, SBNError<LoginRequestError>>) -> Void))
    func makeTransfer(cardId: String,
                      paymentAmount: Double,
                      paymentCurrency: String,
                      souServiceInfoId: String,
                      souServiceId: String?,
                      parameters: [Parameter],
                      paymentPassword: String,
                      completionHandler: @escaping ((Result_<ApiParametersRefillDeposit, SBNError<LoginRequestError>>) -> Void))
    func execute(model: JointExecute?, completionHandler: @escaping ((Result_<JointExecute, SBNError<LoginRequestError>>) -> Void)) 
}

class JointPurchasesPayInteractor: JointPurchasesPayInteractorProtocol {
    private let requestManager: RequestManager
    let inputDatabaseService: PInputDatabaseService
    
    init(inputDatabaseService: PInputDatabaseService) {
        self.requestManager = API.RequestManager
        self.inputDatabaseService = inputDatabaseService
    }
    
    private lazy var selectCardModelFromCreditCardConverter: Converter<CreditCardObject, SelectCardModel> = {
        return SelectCardModelFromCreditCardConverter(databaseService: self.inputDatabaseService)
    }()
    
    func selectCardModels() -> [SelectCardModel] {
        let selectCardModels = DataBaseManager.shared.getContractsObject()?.sortedCreditCards ?? [CreditCardObject]()
        
        return selectCardModels.flatMap({ (creditCard: CreditCardObject) -> SelectCardModel? in
            return self.selectCardModelFromCreditCardConverter.convert(creditCard)
        })
    }
    
    func basicSelectCardModel(from creditCard: CreditCardObject) -> SelectCardModel? {
        return self.selectCardModelFromCreditCardConverter.convert(creditCard)
    }
    
    func connectToDatabaseService(delegate: POutputDatabaseService) {
        inputDatabaseService.connect(output: delegate)
    }
    
    func disconnectFromDatabaseService(delegate: POutputDatabaseService) {
        inputDatabaseService.disconnect(output: delegate)
    }
    
    func stateLoadingBalance(creditCard: CreditCardObject) -> StateLoadingBalance {
        return creditCard.stateLoadingBalance(service: self.inputDatabaseService)
    }
    
    func refreshBalance(creditCard: CreditCardObject) {
        inputDatabaseService.loadBalances(for: [CreditCardObject](arrayLiteral: creditCard))
    }
    
    func basicSelectCardObject() -> CreditCardObject? {
        guard let creditCard = DataBaseManager.shared.getContractsObject()?.basicCreditCard else {
            return nil
        }
        
        return creditCard
    }

    func requestSetJointPurchases(model: AddressBookContactRequest, completionHandler: @escaping ((Result_<AddressBookContactRequest, SBNError<LoginRequestError>>) -> Void)) -> SBNRequest {
        let request = requestManager.request(AddressBookContact.setJointPurchasesRequest(model: model), contentType: .JSONContent) { (result) in
            switch result {
            case .success(let response):
                completionHandler(.success(response))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
        return request
    }
    
    func getCreatorCard(requestId: Int?, completionHandler: @escaping ((Result_<JointCreatorCard, SBNError<LoginRequestError>>) -> Void)) -> SBNRequest {
        let creatorCard = JointCreatorCard(requestId: "\(requestId ?? 0)")
        let request = requestManager.request(JointCreatorCard.getCreatorCard(model: creatorCard), contentType: .JSONContent) { (result) in
            switch result {
            case .success(let card):
                completionHandler(.success(card))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
        return request
    }
    
    func getParametsTransfer(cardId: String,
                             amount: Double,
                             currency: String,
                             beneficiaryCrmId: String?,
                             beneficiaryCardId: String?,
                             beneficiaryCardPan: String?,
                             beneficiaryCardExpire: Date?,
                             completionHandler: @escaping ((Result_<ApiParametersRefillDeposit, SBNError<LoginRequestError>>) -> Void)) {
        RefillDepositRequests.getParametersTransfer(cardId: cardId,
                                                    amount: amount,
                                                    currency: currency,
                                                    beneficiaryCrmId: beneficiaryCrmId,
                                                    beneficiaryCardId: beneficiaryCardId,
                                                    beneficiaryCardPan: beneficiaryCardPan,
                                                    beneficiaryCardExpire: beneficiaryCardExpire,
                                                    souServiceInfoId: nil,
                                                    souServiceId: nil,
                                                    parameters: nil)
            .request(completionHandler: completionHandler)
    }
    
    func makeTransfer(cardId: String,
                      paymentAmount: Double,
                      paymentCurrency: String,
                      souServiceInfoId: String,
                      souServiceId: String?,
                      parameters: [Parameter],
                      paymentPassword: String,
                      completionHandler: @escaping ((Result_<ApiParametersRefillDeposit, SBNError<LoginRequestError>>) -> Void)) {
        RefillDepositRequests.transfer(cardId: cardId,
                                       paymentAmount: paymentAmount,
                                       paymentCurrency: paymentCurrency,
                                       souServiceInfoId: souServiceInfoId,
                                       souServiceId: souServiceId,
                                       parameters: parameters,
                                       paymentPassword: paymentPassword)
            .request(completionHandler: completionHandler)
    }
    
    func execute(model: JointExecute?, completionHandler: @escaping ((Result_<JointExecute, SBNError<LoginRequestError>>) -> Void)) {
        guard let model = model else {
            return
        }
        let _ = requestManager.request(JointExecute.execute(model: model), contentType: .JSONContent) { (result) in
            switch result {
            case .success(let execute):
                completionHandler(.success(execute))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
