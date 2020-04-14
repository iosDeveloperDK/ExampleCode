//
//  JointPurchasesPayJointPurchasesPayPresenter.swift
//  SBOLN-IOS
//
//  Created by Denis on 25/09/2017.
//  Copyright © 2017 Example. All rights reserved.
//

struct JointPurchasesPayModel {
    var crmId: String?
    var requestId: Int?
    var paySum: Double?
    var message: String?
    var cardPan: String?
    var displayName: String?
}

class JointPurchasesPayPresenter: JointPurchasesPayModuleInputProtocol {
    private let minPassword = 5
    fileprivate let mode = "pay"

    weak var view: JointPurchasesPayViewInputProtocol!
    var interactor: JointPurchasesPayInteractorProtocol!
    var router: JointPurchasesPayRouterProtocol!
    var output: JointPurchasesPayModuleOutputProtocol!
    var model: JointPurchasesPayModel?

    var message: String? {
        return model?.message
    }
    var paymentPassword: String = String.empty {
        didSet {
            checkIsEnableMainButton()
        }
    }
    var displayName: String? {
        return self.model?.displayName
    }
    var amount: Double {
        return self.model?.paySum ?? 0
    }
    var canEditAmount: Bool = false
    
    var creditCard: CreditCardObject {
        get {
            return self.selectedCreditCard!
        }
    }
    
    var selectedCreditCard: CreditCardObject?
    fileprivate(set) var parameters: [Parameter] = []
    var transfer: ApiParametersRefillDeposit?
}

extension JointPurchasesPayPresenter: JointPurchasesPayViewOutputProtocol, POutputDatabaseService {
    func viewDidLoad() {
        self.selectedCreditCard = self.interactor.basicSelectCardObject()!
        getParametrs()
    }
    
    func checkIsEnableMainButton() {
        self.view.setEnableMainButton(enable: paymentPassword.isEmpty == false)
    }
    
    func getParametrs() {
        self.view.shouldShowProgressView(true)
        self.getCard { (cardId) in
            self.getParametsTransfer(cardId: cardId, success: { (transfer) in
               logPrint(transfer)
                if let parameters = transfer.parameters {
                    self.parameters = parameters
                }
                self.view.shouldShowProgressView(false)
                self.view.reloadData()
            })
        }
    }
    
    func sendRequest() {
        guard let transfer = self.transfer else {return}
        self.makeTransfer(transfer: transfer, success: {
            self.execute(success: {
                self.router.showSuccessActionScreen(with: ActionBaseContractType.jointPurchases(resultQrId: nil), creditCard: self.creditCard, amount: transfer.paymentAmount ?? 0, requestId: nil)
            })
        })
    }
    
    func getCard(success: @escaping (String)->()) {
        weak var weakSelf = self
        let _ = interactor.getCreatorCard(requestId: self.model?.requestId) { (result) in
            switch result {
            case .success(let card):
                if card.errorInfo?.errorCode == 0 {
                    success(card.cardId ?? "")
                } else {
                    weakSelf?.view.shouldShowProgressView(false)
                    weakSelf?.view.displayError(errorInfo: card.errorInfo, error: nil)
                }
                
            case .failure(let error):
                weakSelf?.view.displayError(errorInfo: nil, error: error)
                weakSelf?.view.shouldShowProgressView(false)
            }
        }
    }
    
    func getParametsTransfer(cardId: String, success: @escaping (ApiParametersRefillDeposit)->()) {
        weak var weakSelf = self
        self.interactor.getParametsTransfer(cardId: self.creditCard.cardId ?? "",
                                            amount: self.model?.paySum ?? 0,
                                            currency: "\(self.creditCard.currencyCode ?? 0)",
            beneficiaryCrmId: self.model?.crmId,
            beneficiaryCardId: cardId,
            beneficiaryCardPan: self.model?.cardPan?.numericCharacters(),
            beneficiaryCardExpire: nil) { (result) in
                switch result {
                case .success(let transfer):
                    if transfer.errorInfo?.errorCode == 0 {
                        weakSelf?.transfer = transfer
                        success(transfer)
                    } else {
                        weakSelf?.view.shouldShowProgressView(false)
                        weakSelf?.view.displayError(errorInfo: transfer.errorInfo, error: nil, closeHandler: {
                            weakSelf?.router.closeCurrentModule(completion: nil)
                        })
                    }
                case .failure(let error):
                    weakSelf?.view.displayError(errorInfo: nil, error: error, closeHandler: {
                        weakSelf?.router.closeCurrentModule(completion: nil)
                    })
                    weakSelf?.view.shouldShowProgressView(false)
                }
        }
    }
    
    func makeTransfer(transfer: ApiParametersRefillDeposit, success: @escaping ()->()) {
        self.view.shouldShowProgressView(true)
        
        weak var weakSelf = self
        self.interactor.makeTransfer(cardId: self.creditCard.cardId ?? "", paymentAmount: self.model?.paySum ?? 0, paymentCurrency: "\(self.creditCard.currencyCode ?? 0)", souServiceInfoId: transfer.souServiceInfoId ?? "", souServiceId: transfer.souServiceId ?? "", parameters: transfer.parameters ?? [], paymentPassword: self.paymentPassword, completionHandler: { (result) in
            switch result {
            case .success(let transfer):
                if transfer.errorInfo?.errorCode == 0 {
                    success()
                } else {
                    weakSelf?.view.shouldShowProgressView(false)
                    weakSelf?.view.displayError(errorInfo: transfer.errorInfo, error: nil)
                    weakSelf?.getParametrs()
                }
            case .failure(let error):
                weakSelf?.view.displayError(errorInfo: nil, error: error)
                weakSelf?.view.shouldShowProgressView(false)
            }
        })
    }
    
    func execute(success: @escaping ()->()) {
        self.view.shouldShowProgressView(true)
        
        weak var weakSelf = self
        let model = JointExecute(requestId: self.model?.requestId, mod: self.mode, amount: self.model?.paySum, message: self.model?.message)
        interactor.execute(model: model) { (result) in
            switch result {
            case .success(let transfer):
                if transfer.errorInfo?.errorCode == 0 {
                    weakSelf?.view.shouldShowProgressView(false)
                    success()
                } else {
                    weakSelf?.view.shouldShowProgressView(false)
                    weakSelf?.view.displayError(errorInfo: transfer.errorInfo, error: nil)
                }
            case .failure(let error):
                weakSelf?.view.displayError(errorInfo: nil, error: error)
                weakSelf?.view.shouldShowProgressView(false)
            }
        }
    }
    
    func chooseNewCreditCard() {
        weak var weakSelf = self
        
        DispatchQueue.main.async {
            let items = self.interactor.selectCardModels()
            let selectedItem = self.interactor.basicSelectCardModel(from: self.creditCard)
            
            let module = ChooseItemModule<SelectCardModel>.assembly(items: items,
                                                                    selectedItem: selectedItem,
                                                                    genericTableView: SelectCardTableView(),
                                                                    completion: { (newItem: Any?) in
                                                                        guard let unwrappedSelf = weakSelf else {
                                                                            return
                                                                        }
                                                                        
                                                                        unwrappedSelf.interactor.connectToDatabaseService(delegate: unwrappedSelf)
                                                                        
                                                                        guard let cardModel: SelectCardModel = newItem as? SelectCardModel else {
                                                                            return
                                                                        }
                                                                        
                                                                        unwrappedSelf.selectedCreditCard = cardModel.creditCard
                                                                        unwrappedSelf.view.updateCreditCard()
                                                                        unwrappedSelf.view.reloadData()
                                                                        unwrappedSelf.getParametrs()
            })
            
            self.router.showSelectCard(module: module)
        }
    }
    
    func stateLoadingBalanceCreditCard() -> StateLoadingBalance {
        return interactor.stateLoadingBalance(creditCard: creditCard)
    }
    
    func refreshBalanceCreditCard() {
        interactor.refreshBalance(creditCard: creditCard)
    }
    
    func viewAppeared() {
        interactor.connectToDatabaseService(delegate: self)
    }
    
    func viewDisappeared() {
        interactor.disconnectFromDatabaseService(delegate: self)
    }
    
    func didChangeStateBalance(for cardId: String, state: StateLoadingBalance) {
        guard cardId == creditCard.cardId else {
            return
        }
        
        self.view.updateCreditCard()
    }
    
    fileprivate func showErrorAlertAndPop(_ error: String) {
        view.presentSimpleAlert(title: "", message: error, closeHandler: { self.router.closeCurrentModule(completion: nil) })
    }
}

